# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::FormulaRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(resolver, inline) }

  describe "#render" do
    it "renders a formula with MathML via Plurimath OMML conversion" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi><mo>=</mo><mi>m</mi><msup><mi>c</mi><mn>2</mn></msup></math></stem>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      renderer.render(formula, doc)

      paragraphs = doc.model.body.paragraphs
      formula_para = paragraphs.find { |p| p.properties&.style&.value == "Formula" }
      expect(formula_para).not_to be_nil

      # Should contain OMML math content in o_math_paras
      expect(formula_para.o_math_paras.length).to be >= 1
    end

    it "falls back to text rendering when MathML conversion fails" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      expect { renderer.render(formula, doc) }.not_to raise_error
    end

    it "renders formula with a name/label" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>r</mi></math></stem>
              <fmt-name>(1)</fmt-name>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      renderer.render(formula, doc)

      paragraphs = doc.model.body.paragraphs
      formula_para = paragraphs.find { |p| p.properties&.style&.value == "Formula" }
      expect(formula_para).not_to be_nil

      # Should contain the label text
      text = formula_para.runs.map { |r| r.text.to_s }.join
      expect(text).to include("(1)")
    end

    it "handles formula without stem element gracefully" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <p>r = 1 %</p>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      expect { renderer.render(formula, doc) }.not_to raise_error
    end
  end
end
