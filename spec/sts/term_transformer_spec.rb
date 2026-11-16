# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::TermTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  describe "#transform_entry" do
    it "builds a termEntry with langSet and tig" do
      term = Metanorma::IsoDocument::Terms::IsoTerm.new
      term.id = "term_3.1"

      pref = Metanorma::IsoDocument::Terms::TermDesignation.new
      pref.text = ["calibration"]
      expr = Metanorma::IsoDocument::Terms::TermExpression.new
      name = Metanorma::IsoDocument::Terms::TermNameElement.new
      name.text = ["calibration"]
      expr.name = [name]
      pref.expression = expr
      term.preferred = [pref]

      result = transformer.transform_entry(term)

      expect(result).to be_a(Sts::TbxIsoTml::TermEntry)
      expect(result.id).to eq("term_3.1")
      xml = result.to_xml
      expect(xml).to include("langSet")
      expect(xml).to include("calibration")
      expect(xml).to include("tig")
    end

    it "handles admitted and deprecated terms" do
      term = Metanorma::IsoDocument::Terms::IsoTerm.new
      term.id = "term_3.2"

      pref = Metanorma::IsoDocument::Terms::TermDesignation.new
      pref.text = ["preferred term"]
      pref.expression = Metanorma::IsoDocument::Terms::TermExpression.new
      name = Metanorma::IsoDocument::Terms::TermNameElement.new
      name.text = ["preferred term"]
      pref.expression.name = [name]
      term.preferred = [pref]

      adm = Metanorma::IsoDocument::Terms::TermDesignation.new
      adm.text = ["admitted term"]
      adm.expression = Metanorma::IsoDocument::Terms::TermExpression.new
      name2 = Metanorma::IsoDocument::Terms::TermNameElement.new
      name2.text = ["admitted term"]
      adm.expression.name = [name2]
      term.admitted = [adm]

      result = transformer.transform_entry(term)
      xml = result.to_xml
      expect(xml).to include("preferredTerm")
      expect(xml).to include("admittedTerm")
      expect(xml).to include("preferred term")
      expect(xml).to include("admitted term")
    end

    it "includes termnote and termexample" do
      term = Metanorma::IsoDocument::Terms::IsoTerm.new
      term.id = "term_3.3"

      pref = Metanorma::IsoDocument::Terms::TermDesignation.new
      pref.text = ["test term"]
      pref.expression = Metanorma::IsoDocument::Terms::TermExpression.new
      name = Metanorma::IsoDocument::Terms::TermNameElement.new
      name.text = ["test term"]
      pref.expression.name = [name]
      term.preferred = [pref]

      tn = Metanorma::IsoDocument::Terms::TermNote.new
      tn_p = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
      tn_p.text = ["Note to entry"]
      tn.p = [tn_p]
      term.termnote = [tn]

      result = transformer.transform_entry(term)
      xml = result.to_xml
      expect(xml).to include("<note")
      expect(xml).to include("test term")
    end
  end

  describe "term definition with monospace text" do
    # metanorma-pdfa#121: a `+monospace+` phrase in a term definition
    # serializes as <tt> in the semantic XML; the definition's inline
    # content walks TtElement, whose content accessor is `text`
    # (collection), like its SupElement sibling — not `content`.
    let(:tt_xml) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
          <bibdata type="standard">
            <title language="en" type="main">Test</title>
            <docidentifier>ISO 9999</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <terms id="terms1" obligation="normative">
              <title>Terms and definitions</title>
              <term id="term1">
                <preferred>
                  <expression><name>calibration</name></expression>
                </preferred>
                <definition id="def1">
                  <verbal-definition id="vd1">
                    <p id="p1">definition with <tt>monospace</tt> inside</p>
                  </verbal-definition>
                </definition>
              </term>
            </terms>
          </sections>
        </metanorma>
      XML
    end

    it "transforms the definition to STS without error" do
      expect { Metanorma::Iso::Sts.convert(tt_xml) }.not_to raise_error
    end

    it "carries the monospace phrase in the STS definition" do
      sts = Metanorma::Iso::Sts.convert(tt_xml)
      expect(sts).to match(%r{<(?:tbx:)?definition[^>]*>.*monospace.*</(?:tbx:)?definition}m)
      expect(sts).to match(%r{<(?:tbx:)?monospace>})
    end
  end
end
