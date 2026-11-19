# frozen_string_literal: true

require_relative "spec_helper"

# Shared MathML → OMML conversion for stem content. Both the block
# formula renderer and the inline stem renderer convert through this
# module; the extraction covers the semantic stem shape (math under
# :math) and the presentation fmt-stem shape (math under <semx>).
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

  let(:simple_mathml) do
    '<math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi></math>'
  end

  describe "#stem_mathml" do
    it "extracts MathML from a semantic stem" do
      stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
        "<stem type=\"MathML\">#{simple_mathml}<asciimath>E</asciimath></stem>",
      )

      mathml = converter.stem_mathml(stem)
      expect(mathml).to include("<math")
      expect(mathml).to include("<mi>E</mi>")
    end

    it "extracts MathML from a presentation fmt-stem semx wrapper" do
      stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(
        "<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"s1\">" \
        "#{simple_mathml}<asciimath>E</asciimath></semx></fmt-stem>",
      )

      expect(converter.stem_mathml(stem)).to include("<mi>E</mi>")
    end

    it "returns nil for a stem carrying only AsciiMath" do
      stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(
        '<stem type="AsciiMath"><asciimath>E</asciimath></stem>',
      )

      expect(converter.stem_mathml(stem)).to be_nil
    end

    it "returns nil for nil input" do
      expect(converter.stem_mathml(nil)).to be_nil
    end
  end

  describe "#omml_para_from_mathml" do
    it "converts a MathML string into an Omml oMathPara model" do
      para = converter.omml_para_from_mathml(simple_mathml)
      expect(para).to be_a(Omml::Models::OMathPara)
      expect(para.o_math).not_to be_empty
    end

    it "returns nil for input Plurimath cannot parse" do
      expect(converter.omml_para_from_mathml("<<<")).to be_nil
    end
  end

  describe "#inline_omath_models" do
    it "returns inline oMath models for a stem with MathML" do
      stem = Metanorma::Document::Components::Inline::StemInlineElement.from_xml(
        "<stem block=\"false\" type=\"MathML\" id=\"s1\">#{simple_mathml}" \
        "<asciimath>E</asciimath></stem>",
      )

      omaths = converter.inline_omath_models(stem)
      expect(omaths).not_to be_nil
      expect(omaths.length).to eq(1)
      expect(omaths.first).to be_a(Omml::Models::CTOMath)
    end

    it "returns nil for a stem without MathML" do
      stem = Metanorma::Document::Components::Inline::StemInlineElement.from_xml(
        '<stem block="false" type="AsciiMath"><asciimath>E</asciimath></stem>',
      )

      expect(converter.inline_omath_models(stem)).to be_nil
    end
  end
end
