# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ClauseRenderer do
  let(:adapter) { build_adapter }

  context "with a unit in presentation heading and body text" do
    def stem_xml
      <<~XML.strip
        <stem type="MathML">
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <mrow><mn>80</mn><mo rspace="thickmathspace">⁢</mo>
              <mrow xref="U_km"><mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow>
            </mrow>
          </math><asciimath>80 "unitsml(km)"</asciimath>
        </stem>
      XML
    end
    let(:xml) do
      minimal_iso_xml(<<~INNER)
        <sections><clause id="c1">
          <fmt-title><semx element="title" source="t1">Altitude #{stem_xml}</semx></fmt-title>
          <p>Altitude #{stem_xml}</p>
        </clause></sections>
      INNER
    end
    let(:paragraphs) do
      convert_and_extract(adapter, xml) { |pkg| pkg.document.body.paragraphs }
    end
    let(:heading_text) do
      heading = paragraphs.find { |p| para_style_value(p) == "Heading1" }
      heading.runs.map { |run| run_text(run) }.join
    end
    let(:body_texts) do
      body = paragraphs.reject { |p| para_style_value(p).to_s.start_with?("Heading") }
      body.map { |p| p.runs.map { |run| run_text(run) }.join }
    end

    it "renders the value and unit in heading runs" do
      expect(heading_text).to eq("Altitude 80 km")
    end

    it "omits the source unit macro from heading runs" do
      expect(heading_text).not_to include("unitsml(")
    end

    # Body stems render as inline OMML (the heading stays text).
    let(:body_math_tokens) do
      body = paragraphs.find { |p| p.o_maths.any? }
      body.o_maths.map { |m| m.to_xml.scan(%r{<m:t[^>]*>([^<]*)</m:t>}).flatten }
    end

    it "renders the unit as an inline equation in body paragraphs" do
      expect(body_math_tokens).to eq([%w[80 km]])
      expect(body_texts).to include("Altitude ")
    end

    context "with a power and quotient in the unit" do
      def stem_xml
        '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
          '<mrow><mn>80</mn><mo>⁢</mo><mstyle mathvariant="normal">' \
          "<mfrac><msup><mi>m</mi><mn>2</mn></msup><mi>s</mi></mfrac>" \
          '</mstyle></mrow></math><asciimath>80 "unitsml(m^2/s)"</asciimath></stem>'
      end

      it "preserves unit structure in the heading" do
        expect(heading_text).to eq("Altitude 80 (m²/s)")
      end

      it "preserves unit structure in body paragraphs" do
        expect(body_math_tokens.flatten).to eq(%w[80 m 2 s])
      end
    end
  end

  it "renders clause title with Heading1 at depth 1" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p).to_s.start_with?("Heading")
      end
      expect(heading_paras.map { |p| para_style_value(p) })
        .to include("Heading1"),
        "top-level clause title should use Heading1, got: #{heading_paras.inspect}"
    end
  end

  context "with a numbered introduction clause" do
    let(:xml) do
      minimal_iso_xml(<<~INNER)
        <preface><introduction id="intro">
          <title>Introduction</title>
          <clause id="intro-1">
            <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">0</semx>.<semx element="autonum">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">Background</semx></fmt-title>
          </clause>
        </introduction></preface>
      INNER
    end

    let(:paragraphs) do
      convert_and_extract(adapter, xml) { |pkg| pkg.document.body.paragraphs }
    end

    let(:heading) do
      paragraphs.find do |para|
        para.runs.map { |run| run_text(run) }.join.include?("Background")
      end
    end

    it "renders the introduction clause with the a2 style" do
      expect(para_style_value(heading)).to eq("a2")
    end

    it "keeps the introduction clause number in the heading text" do
      expect(heading.runs.map { |run| run_text(run) }.join).to start_with("0.1")
    end

    it "cancels the numbering inherited from the annex style" do
      expect(heading.properties.numbering_properties&.num_id&.value).to eq(0)
    end
  end

  it "nests clause depth (Heading2 under Heading1)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Top</title>
          <clause id="c1a"><title>Sub</title><p>Body.</p></clause>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p).to_s.start_with?("Heading")
      end
      levels = heading_paras.map { |p| para_style_value(p) }
      expect(levels).to include("Heading1"),
        "top-level should be Heading1, got: #{levels.inspect}"
      expect(levels).to include("Heading2"),
        "nested should be Heading2, got: #{levels.inspect}"
    end
  end

  it "walks child content after rendering title" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body paragraph one.</p>
          <p>Body paragraph two.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.flat_map { |p| p.runs.map(&:text).compact }
      joined = texts.join
      expect(joined).to include("Body paragraph one")
      expect(joined).to include("Body paragraph two")
    end
  end
end
