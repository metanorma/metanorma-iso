# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ImageRenderer do
  let(:adapter) { build_adapter }
  let(:real_image_path) { "spec/assets/rice_image1.png" }

  def image_paragraphs(pkg)
    pkg.document.body.paragraphs.select do |p|
      p.properties&.style&.value.to_s.start_with?("Dimension")
    end
  end

  it "applies Dimension100 when no explicit width is set" do
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
      styles = image_paragraphs(pkg).map { |p| p.properties.style.value }
      expect(styles).to include("Dimension100"),
        "image with no width should use Dimension100, got: #{styles.inspect}"
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

  describe ".dimension_key_for" do
    it "returns :dimension_100 when pct is nil" do
      expect(described_class.dimension_key_for(nil)).to eq(:dimension_100)
    end

    it "returns :dimension_100 at or above 90%" do
      expect(described_class.dimension_key_for(90)).to eq(:dimension_100)
      expect(described_class.dimension_key_for(95)).to eq(:dimension_100)
      expect(described_class.dimension_key_for(100)).to eq(:dimension_100)
    end

    it "returns :dimension_75 between 60% and 89%" do
      expect(described_class.dimension_key_for(60)).to eq(:dimension_75)
      expect(described_class.dimension_key_for(70)).to eq(:dimension_75)
      expect(described_class.dimension_key_for(89)).to eq(:dimension_75)
    end

    it "returns :dimension_50 below 60%" do
      expect(described_class.dimension_key_for(10)).to eq(:dimension_50)
      expect(described_class.dimension_key_for(40)).to eq(:dimension_50)
      expect(described_class.dimension_key_for(59)).to eq(:dimension_50)
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
