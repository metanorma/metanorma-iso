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
end
