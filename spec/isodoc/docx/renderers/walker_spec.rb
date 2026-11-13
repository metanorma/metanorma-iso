# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::Walker do
  # Records every dispatch call as a [node, doc] pair.
  let(:calls) { [] }
  let(:dispatcher) { ->(node, doc) { calls << [node, doc] } }
  let(:walker) { described_class.new(dispatcher) }
  let(:doc) { Object.new }

  describe "#walk" do
    it "dispatches each element child of an ordered-content node" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <p>One.</p>
            <p>Two.</p>
          </clause>
        </sections>
      INNER

      clause = parse_iso_document(xml).sections.clause.first
      walker.walk(clause, doc)

      # Title + 2 paragraphs = 3 element children dispatched
      expect(calls.length).to eq(3)
      expect(calls.map(&:first)).to all be_a(Lutaml::Model::Serializable)
    end

    it "skips text children (block-level walk only)" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <p>Body.</p>
          </clause>
        </sections>
      INNER

      clause = parse_iso_document(xml).sections.clause.first
      walker.walk(clause, doc)

      # Clause's children are title (element) and p (element) — no text nodes
      # at clause level. Verify only elements are dispatched.
      expect(calls.length).to eq(2)
    end
  end

  describe "#dispatch" do
    it "dispatches a single node through the configured dispatcher" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
            </formula>
          </clause>
        </sections>
      INNER

      formula = parse_iso_document(xml).sections.clause.first.formulas.first
      walker.dispatch(formula, doc)

      expect(calls).to eq([[formula, doc]])
    end

    it "does not recurse into the node's children" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
              <p>Where:</p>
            </formula>
          </clause>
        </sections>
      INNER

      formula = parse_iso_document(xml).sections.clause.first.formulas.first
      walker.dispatch(formula, doc)

      # dispatch sends only the formula itself — its stem/p are not visited
      expect(calls).to eq([[formula, doc]])
    end
  end

  describe "#walk_attribute" do
    it "dispatches each element in a collection-valued attribute" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
              <p>Where:</p>
              <p>x is the value</p>
            </formula>
          </clause>
        </sections>
      INNER

      formula = parse_iso_document(xml).sections.clause.first.formulas.first
      walker.walk_attribute(formula, :p, doc)

      expect(calls.length).to eq(2)
    end

    it "is a no-op when the attribute is missing" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
            </formula>
          </clause>
        </sections>
      INNER

      formula = parse_iso_document(xml).sections.clause.first.formulas.first
      expect { walker.walk_attribute(formula, :nonexistent, doc) }.not_to raise_error
      expect(calls).to be_empty
    end

    it "is a no-op when the attribute value is nil" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></stem>
            </formula>
          </clause>
        </sections>
      INNER

      formula = parse_iso_document(xml).sections.clause.first.formulas.first
      # :dl is a valid attribute on formula but unset in this XML
      expect { walker.walk_attribute(formula, :dl, doc) }.not_to raise_error
      expect(calls).to be_empty
    end

    it "is a no-op when the node is not a Lutaml serializable" do
      walker.walk_attribute("plain string", :p, doc)
      expect(calls).to be_empty
    end
  end
end
