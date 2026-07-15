# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ImageRenderer do
  let(:adapter) { build_adapter }
  let(:real_image_path) { "spec/assets/rice_image1.png" }

  it "uses FigureGraphic for images inside a figure (matches reference DOCX)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <image src="#{real_image_path}" mimetype="image/png"/>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("FigureGraphic"),
        "figure-wrapped image should use FigureGraphic, got: #{styles.inspect}"
    end
  end

  it "renders alt text as fallback when source cannot be resolved" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <image src="/does/not/exist.png" mimetype="image/png" alt="Missing diagram"/>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.flat_map do |p|
        p.runs.map(&:text).compact
      end
      expect(texts.join).to include("Missing diagram"),
        "fallback should include alt text, got: #{texts.inspect}"
    end
  end

  it "is callable directly via #call (used by FigureRenderer)" do
    renderer = described_class.new(
      resolver: adapter.resolver,
      context: adapter.context,
      inline_renderer: nil,
      walker: nil,
    )
    expect(renderer.method(:call)).to be_a(Method)
  end
end
