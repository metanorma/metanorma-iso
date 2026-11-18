# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::FigureRenderer do
  let(:adapter) { build_adapter }

  let(:subfigure_xml) do
    tiny_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
    subfigures = %w[a b c].map do |label|
      <<~XML
        <figure id="fig-#{label}">
          <fmt-name>#{label})</fmt-name>
          <image src="#{tiny_png}" width="100" height="100"/>
        </figure>
      XML
    end.join
    minimal_iso_xml(<<~XML)
      <sections><clause id="c1"><title>Scope</title>
        <figure id="fig"><fmt-name>Figure 1</fmt-name>
          #{subfigures}
        </figure>
      </clause></sections>
    XML
  end

  let(:subfigure_image_counts) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(subfigure_xml, path)
      Zip::File.open(path) do |zip|
        document = Nokogiri::XML(zip.read("word/document.xml"))
        relationships = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
        embeds = document.xpath(
          "//a:blip/@r:embed",
          "a" => "http://schemas.openxmlformats.org/drawingml/2006/main",
          "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        ).map(&:value)
        targets = embeds.map do |id|
          relationships.at_xpath("//*[@Id='#{id}']")["Target"]
        end

        parts = targets.uniq.count do |target|
          zip.find_entry("word/#{target}")
        end
        { placements: embeds.size, parts: parts }
      end
    end
  end

  it "packages one image part for each subfigure a/b/c" do
    expect(subfigure_image_counts).to eq(placements: 3, parts: 3)
  end

  it "renders figure name with Figuretitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <image src="spec/fixtures/dummy.png" mimetype="image/png" height="100" width="100"/>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).to include("Figuretitle"),
        "figure name should use Figuretitle, got: #{styles.inspect}"
    end
  end

  it "renders figure notes with Figurenote style (not generic Noteindent)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <note id="fnote1"><p>Source: own elaboration.</p></note>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).to include("Figurenote"),
        "figure note should use Figurenote, got: #{styles.inspect}"
    end
  end
end
