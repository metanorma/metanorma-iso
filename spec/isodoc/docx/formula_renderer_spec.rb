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
      formula_para = paragraphs.find { |p| para_style_value(p) == "Formula" }
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
      formula_para = paragraphs.find { |p| para_style_value(p) == "Formula" }
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

  describe "#render with a walker wired (extras dispatch)" do
    let(:walker) do
      IsoDoc::Iso::Docx::Renderers::Walker.new(
        ->(node, d) { adapter.send(:dispatch, node, d) },
      )
    end

    let(:wired_renderer) do
      described_class.new(resolver, inline, context: context, walker: walker)
    end

    before do
      adapter.send(:reset_state, doc)
    end

    it "renders the where-clause definitions wrapped in <key>" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>w</mi></math></stem>
              <key>
                <dl>
                  <dt>w</dt>
                  <dd><p>is the mass fraction of grains with a defect;</p></dd>
                </dl>
              </key>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      wired_renderer.render(formula, doc)

      text = doc.model.body.paragraphs.map do |p|
        p.runs.map { |r| run_text(r) }.join
      end.join("\n")

      expect(text).to include("is the mass fraction of grains with a defect")
    end

    it "renders a bare <dl> sibling (semantic form) alongside the key form" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>a</mi></math></stem>
              <dl>
                <dt>a</dt>
                <dd><p>is the standalone list term;</p></dd>
              </dl>
              <key>
                <dl>
                  <dt>b</dt>
                  <dd><p>is the key-wrapped term;</p></dd>
                </dl>
              </key>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      wired_renderer.render(formula, doc)

      text = doc.model.body.paragraphs.map do |p|
        p.runs.map { |r| run_text(r) }.join
      end.join("\n")

      expect(text).to include("is the standalone list term")
      expect(text).to include("is the key-wrapped term")
    end

    it "renders key paragraphs that accompany the symbol list" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
              <key>
                <dl>
                  <dt>x</dt>
                  <dd><p>is a value;</p></dd>
                </dl>
              </key>
              <p>where the value is dimensionless.</p>
            </formula>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      formula = model.sections.clause.first.formulas.first

      wired_renderer.render(formula, doc)

      text = doc.model.body.paragraphs.map do |p|
        p.runs.map { |r| run_text(r) }.join
      end.join("\n")

      expect(text).to include("is a value")
      expect(text).to include("where the value is dimensionless")
    end
  end
end
