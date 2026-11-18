# frozen_string_literal: true

require_relative "../spec_helper"

# Inline stem symbols used to render as empty runs: stem_fallback_text
# read the :asciimath attribute but the models return an Asciiml object
# (semantic <stem>) or a collection nested inside <semx> (presentation
# <fmt-stem>), so the String check always missed and every stem-only
# table cell and prose symbol fell through to an empty collect_text.
RSpec.describe IsoDoc::Iso::Docx::InlineRenderers::StemRenderer do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(inline) }

  def render_to_text(element)
    para = Uniword::Builder::ParagraphBuilder.new
    renderer.render(element, para)
    built = para.build
    built ? built.text : ""
  end

  it "renders a semantic stem via its asciimath value" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<msub><mi>g</mi><mi>n</mi></msub></math><asciimath>g_n</asciimath></stem>',
    )

    expect(render_to_text(stem)).to eq("g_n")
  end

  it "renders a presentation fmt-stem via the semx-wrapped asciimath" do
    stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<msub><mi>g</mi><mi>n</mi></msub></math><asciimath>g_n</asciimath></semx></fmt-stem>',
    )

    expect(render_to_text(stem)).to eq("g_n")
  end

  it "renders a bare-string asciimath stem unchanged" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="AsciiMath"><asciimath>M</asciimath></stem>',
    )

    expect(render_to_text(stem)).to eq("M")
  end

  def numeric_stem(value)
    Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mn>#{value}</mn></math></semx></fmt-stem>",
    )
  end

  ["−12,50", "1.250E-6"].each do |value|
    it "renders #{value} from MathML without reparsing it", :aggregate_failures do
      allow(Plurimath::Mathml::Parser).to receive(:new).and_call_original
      expect(render_to_text(numeric_stem(value))).to eq(value)
      expect(Plurimath::Mathml::Parser).not_to have_received(:new)
    end
  end

  it "preserves operators when MathML contains more than one token" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mn>12</mn><mo>+</mo><mi>x</mi></math></stem>",
    )

    expect(render_to_text(stem)).to eq("12 + x")
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

  it "uses rendered MathML instead of the presentation source macro" do
    expect(render_to_text(presentation_unit_stem)).to eq("80 km")
  end

  def structured_unit_stem(mathml)
    Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="s1">' \
      "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">#{mathml}</math>" \
      '<asciimath>"unitsml(unit)"</asciimath></semx></fmt-stem>',
    )
  end

  {
    "<msup><mi>m</mi><mn>2</mn></msup>" => "m²",
    "<mrow><mi>m</mi><mo>⋅</mo><msup><mi>s</mi><mrow><mo>−</mo>" \
    "<mn>1</mn></mrow></msup></mrow>" => "m⋅s⁻¹",
    "<msub><mi>m</mi><mn>0</mn></msub>" => "m₀",
    "<mfrac><mi>m</mi><mi>s</mi></mfrac>" => "(m/s)",
    "<msup><mfrac><mi>m</mi><mi>s</mi></mfrac><mn>2</mn></msup>" => "(m/s)²",
    "<msup><mi>s</mi><mn>-1</mn></msup>" => "s⁻¹",
    "<msubsup><mi>m</mi><mn>0</mn><mn>2</mn></msubsup>" => "m₀²",
    "<msup><mrow><mi>m</mi><mo>⋅</mo><mi>s</mi></mrow><mn>2</mn></msup>" => "(m⋅s)²",
    "<msup><mi>m</mi><mi>n</mi></msup>" => "m^(n)",
  }.each do |mathml, expected|
    it "preserves unit structure as #{expected}" do
      expect(render_to_text(structured_unit_stem(mathml))).to eq(expected)
    end
  end

  it "uses rendered MathML instead of the semantic source macro" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<mi>km</mi></math><asciimath>"unitsml(km)"</asciimath></stem>',
    )

    expect(render_to_text(stem)).to eq("km")
  end

  it "preserves the source text when rendered MathML is unavailable" do
    stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
      '<stem type="AsciiMath"><asciimath>"unitsml(km)"</asciimath></stem>',
    )

    expect(render_to_text(stem)).to eq('"unitsml(km)"')
  end
end
