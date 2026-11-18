# frozen_string_literal: true

require_relative "spec_helper"

# 1.17.0 parity: a stem consisting of a bare number renders as plain
# text in the Word output, not as an OMML equation object and not
# dropped (metanorma-iso#1764: stem:[0]/stem:[1] vanished from table
# cells whose presentation stems carry no asciimath fallback). Structured
# stems keep the equation path.
RSpec.describe IsoDoc::Iso::Docx::MathConversion do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }

  # MathConversion is a module; exercise it through the renderer that
  # owns stem dispatch (InlineRenderer includes it).
  let(:converter) do
    IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc)
  end

  def stem_with(mathml_body)
    Metanorma::Document::Components::Inline::StemInlineElement.from_xml(
      "<stem block=\"false\" type=\"MathML\" id=\"s1\">" \
      "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">#{mathml_body}</math>" \
      "</stem>",
    )
  end

  def rendered_paragraph(stem)
    para = Uniword::Builder::ParagraphBuilder.new
    converter.dispatch_inline(stem, para)
    para.model
  end

  it "extracts the digits of a bare number stem" do
    expect(converter.number_only_stem_text(stem_with("<mn>0</mn>"))).to eq("0")
    expect(converter.number_only_stem_text(stem_with("<mn>12</mn>"))).to eq("12")
  end

  it "keeps structured stems on the equation path" do
    expect(converter.number_only_stem_text(
      stem_with("<msup><mn>2</mn><mn>0</mn></msup>")
    )).to be_nil
    expect(converter.number_only_stem_text(
      stem_with("<mi>x</mi>")
    )).to be_nil
    expect(converter.number_only_stem_text(
      stem_with("<mn>0</mn><mo>+</mo><mn>1</mn>")
    )).to be_nil
  end

  it "renders a number-only stem as a text run" do
    model = rendered_paragraph(stem_with("<mn>0</mn>"))

    texts = model.runs.map { |run| Array(run.text).join }
    expect(texts.join).to eq("0")
    expect(model.o_maths).to be_empty
    expect(model.o_math_paras).to be_empty
  end

  it "renders a structured stem as an equation object" do
    model = rendered_paragraph(
      stem_with("<msup><mn>2</mn><mn>0</mn></msup>"),
    )

    expect(model.o_maths.length).to eq(1)
  end

  # Presentation bare-number stems carry no MathML at all: mnconvert
  # emits the digit as plain text inside the semx wrapper, with a
  # <latexmath> fallback the model does not map. The cell rendered as
  # an empty run before the semx descent (metanorma-iso#1764).
  it "renders a MathML-less bare-number fmt-stem as a text run" do
    stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="_x">' \
      '0<latexmath>0</latexmath></semx></fmt-stem>',
    )

    model = rendered_paragraph(stem)

    texts = model.runs.map { |run| Array(run.text).join }
    expect(texts.join).to eq("0")
    expect(model.o_maths).to be_empty
  end

  it "keeps a MathML-bearing fmt-stem on the equation path" do
    stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
      '<fmt-stem type="MathML"><semx element="stem" source="_y">' \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mstyle displaystyle=\"false\"><mi>x</mi></mstyle></math>" \
      "<latexmath>x</latexmath></semx></fmt-stem>",
    )

    model = rendered_paragraph(stem)

    expect(model.o_maths.length).to eq(1)
  end
end
