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
end
