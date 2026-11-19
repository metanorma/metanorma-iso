# frozen_string_literal: true

require_relative "../spec_helper"

# Inline stems carry MathML in the presentation XML. They render as an
# inline OMML equation (oMath) via the shared MathConversion pipeline —
# the same Plurimath path block formulas use — so the equation appears
# in Word exactly once as a native formula (isodoc#898: the LaTeX source
# used to be emitted as text, twice for semantic+fmt stem pairs). Stems
# without MathML fall back to their AsciiMath textual representation.
RSpec.describe IsoDoc::Iso::Docx::InlineRenderers::StemRenderer do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(inline) }

  def omml_xml(element)
    para = Uniword::Builder::ParagraphBuilder.new
    renderer.render(element, para)
    para.build.o_maths.map(&:to_xml)
  end

  def omml_tokens(element)
    omml_xml(element).map { |xml| xml.scan(%r{<m:t[^>]*>([^<]*)</m:t>}).flatten }
  end

  def omml_structure(element)
    omml_xml(element).join.scan(/<m:(sSup|sSubSup|sSub|f)\b/).flatten
  end

  def render_built(element)
    para = Uniword::Builder::ParagraphBuilder.new
    renderer.render(element, para)
    para.build
  end

  it "renders a semantic stem with MathML as an inline OMML equation" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<msub><mi>g</mi><mi>n</mi></msub></math><asciimath>g_n</asciimath></stem>',
    )

    built = render_built(stem)
    expect(built.o_maths.length).to eq(1)
    # The AsciiMath source must not leak as text next to the equation.
    expect(built.text).to eq("")
  end

  # rice "100 mm ± 5 mm": the plus-minus is a lone <mo> stem. It is not
  # lost: it renders as an inline oMath whose m:t holds the sign (a w:t-only
  # text extractor does not see it, which is how it was misread as dropped).
  it "keeps a lone plus-minus operator stem as an oMath carrying the sign" do
    stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1"><math ' \
      'xmlns="http://www.w3.org/1998/Math/MathML"><mo>±</mo></math></semx></fmt-stem>',
    )
    expect(omml_tokens(stem)).to eq([["±"]])
  end

  it "renders a presentation fmt-stem via the semx-wrapped MathML as OMML" do
    stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<msub><mi>g</mi><mi>n</mi></msub></math><asciimath>g_n</asciimath></semx></fmt-stem>',
    )

    built = render_built(stem)
    expect(built.o_maths.length).to eq(1)
    expect(built.text).to eq("")
  end

  it "falls back to the asciimath text run when the stem carries no MathML" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="AsciiMath"><asciimath>M</asciimath></stem>',
    )

    built = render_built(stem)
    expect(built.o_maths).to be_empty
    expect(built.text).to eq("M")
  end

  def numeric_stem(value)
    Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mn>#{value}</mn></math></semx></fmt-stem>",
    )
  end

  it "keeps a digits-only number as a text run without reparsing it", :aggregate_failures do
    allow(Plurimath::Mathml::Parser).to receive(:new).and_call_original
    built = render_built(numeric_stem("12"))
    expect(built.text).to eq("12")
    expect(built.o_maths).to be_empty
    expect(Plurimath::Mathml::Parser).not_to have_received(:new)
  end

  # Same shapes Adapter#flatten_number_stems flattens, so a stem renders
  # identically before and after flattening.
  ["−12,50", "1.250E-6"].each do |value|
    it "renders #{value} as a text run, not an equation", :aggregate_failures do
      built = render_built(numeric_stem(value))
      expect(built.text).to eq(value)
      expect(built.o_maths).to be_empty
    end
  end

  it "preserves operators when MathML contains more than one token" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mn>12</mn><mo>+</mo><mi>x</mi></math></stem>",
    )

    expect(omml_tokens(stem)).to eq([%w[12 + x]])
  end

  def presentation_unit_stem
    Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mn>80</mn>' \
      '<mo rspace="thickmathspace">⁢</mo><mrow xref="U_km">' \
      '<mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow></mrow></math>' \
      '<asciimath>80 "unitsml(km)"</asciimath></semx></fmt-stem>',
    )
  end

  it "uses rendered MathML instead of the presentation source macro", :aggregate_failures do
    built = render_built(presentation_unit_stem)
    expect(omml_tokens(presentation_unit_stem)).to eq([%w[80 km]])
    expect(built.text).to eq("")
  end

  it "renders a unit stem as text inside a heading", :aggregate_failures do
    allow(inline).to receive(:in_heading?).and_return(true)
    built = render_built(presentation_unit_stem)
    expect(built.text).to eq("80 km")
    expect(built.o_maths).to be_empty
  end

  def structured_unit_stem(mathml)
    Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">#{mathml}</math>" \
      '<asciimath>"unitsml(unit)"</asciimath></semx></fmt-stem>',
    )
  end

  # MathML => [OMML structure elements, text tokens]
  {
    "<msup><mi>m</mi><mn>2</mn></msup>" => [%w[sSup], %w[m 2]],
    "<mrow><mi>m</mi><mo>⋅</mo><msup><mi>s</mi><mrow><mo>−</mo>" \
    "<mn>1</mn></mrow></msup></mrow>" => [%w[sSup], %w[m ⋅ s − 1]],
    "<msub><mi>m</mi><mn>0</mn></msub>" => [%w[sSub], %w[m 0]],
    "<mfrac><mi>m</mi><mi>s</mi></mfrac>" => [%w[f], %w[m s]],
    "<msup><mfrac><mi>m</mi><mi>s</mi></mfrac><mn>2</mn></msup>" => [%w[sSup f], %w[m s 2]],
    "<msup><mi>s</mi><mn>-1</mn></msup>" => [%w[sSup], %w[s -1]],
    "<msubsup><mi>m</mi><mn>0</mn><mn>2</mn></msubsup>" => [%w[sSubSup], %w[m 0 2]],
    "<msup><mrow><mi>m</mi><mo>⋅</mo><mi>s</mi></mrow><mn>2</mn></msup>" => [%w[sSup], %w[m ⋅ s 2]],
    "<msup><mi>m</mi><mi>n</mi></msup>" => [%w[sSup], %w[m n]],
  }.each do |mathml, (structure, tokens)|
    it "preserves unit structure as #{structure.join('/')} over #{tokens.join(' ')}", :aggregate_failures do
      stem = structured_unit_stem(mathml)
      expect(omml_structure(stem)).to eq(structure)
      expect(omml_tokens(stem)).to eq([tokens])
    end
  end

  it "uses rendered MathML instead of the semantic source macro" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<mi>km</mi></math><asciimath>"unitsml(km)"</asciimath></stem>',
    )

    expect(omml_tokens(stem)).to eq([%w[km]])
  end

  it "preserves the source text when rendered MathML is unavailable" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="AsciiMath"><asciimath>"unitsml(km)"</asciimath></stem>',
    )

    expect(render_built(stem).text).to eq('"unitsml(km)"')
  end
end
