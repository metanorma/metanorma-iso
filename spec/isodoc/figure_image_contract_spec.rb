# frozen_string_literal: true

require "spec_helper"

# The image render contract (metanorma-iso#1776):
#   XML/HTML output keeps PNGs as PNGs and SVGs as SVGs — the SVG
#   reaches the HTML output as an SVG (file reference or SVG data
#   URI), never converted to PNG. Only the Word lane converts SVG to
#   EMF. A figure whose file sits next to the document (the ISO 10303
#   layout: bare targets beside the schema sources) renders; it is
#   never silently dropped from the output.
RSpec.describe "figure image render contract" do
  let(:svg) do
    "<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10'>" \
      "<rect width='10' height='10' fill='blue'/></svg>"
  end

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write("diagram.svg", svg)
        example.run
      end
    end
  end

  def convert(input, converter)
    pres = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
    converter.new({}).convert("test", pres, true)
  end

  def input_for(src, mimetype)
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="scope" type="scope" displayorder="1">
            <fmt-title id="_">Scope</fmt-title>
            <figure id="N">
              <fmt-name id="_">Figure 1</fmt-name>
              <image src="#{src}" id="_1" mimetype="#{mimetype}"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  it "renders an SVG figure next to the document as an SVG image" do
    html = convert(input_for("diagram.svg", "image/svg+xml"),
                   IsoDoc::Iso::HtmlConvert)

    expect(html).to include("<img")
    # SVG stays SVG: the image src is the SVG asset itself (file
    # reference or SVG data URI) — never a PNG conversion.
    expect(html).to match(%r{src="(([^"]*)diagram\.svg|data:image/svg\+xml)})
    expect(html).not_to include("data:image/png")
  end

  it "renders a PNG figure as a PNG image" do
    png_path = File.join(File.dirname(__FILE__), "..", "fixtures",
                         "pixel.png")
    FileUtils.cp(png_path, "pixel.png")
    html = convert(input_for("pixel.png", "image/png"),
                   IsoDoc::Iso::HtmlConvert)

    expect(html).to include("<img")
    expect(html).to match(%r{src="(([^"]*)pixel\.png|data:image/png)})
    expect(html).not_to include("data:image/svg+xml")
  end
end
