require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::SectionSequenceRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml, vocab: false)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    s = Metanorma::Iso::Validation::ConverterState.new(
      document: "spec", vocab: vocab
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: s, shared: nil)
  end

  describe "#check with empty document" do
    it "emits ISO_32 / ISO_36 (missing clause, no annex/refs)" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      # Faithful to the original: empty doc skips ISO_28 emission (seqcheck
      # early-returns on nil), but step_body and step_end still fire.
      expect(issues.map(&:code)).to include("ISO_32")
    end
  end

  describe "#check with well-formed document" do
    let(:well_formed) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface>
            <foreword id="fw"><p>fw</p></foreword>
          </preface>
          <sections>
            <clause type="scope" id="scope"><title>Scope</title></clause>
            <terms id="terms"><title>Terms</title></terms>
            <clause id="c1"><title>Body</title></clause>
          </sections>
          <bibliography>
            <references normative="true"><title>Norm Refs</title></references>
            <references normative="false"><title>Bibliography</title></references>
          </bibliography>
        </metanorma>
      XML
    end

    it "does not flag ISO_28 (initial foreword present)" do
      issues = rule.check(context_with(well_formed))
      expect(issues.map(&:code)).not_to include("ISO_28")
    end
  end

  describe "#check with a BSI-shaped document" do
    # metanorma-bsi#664 originally exposed nil element_order under leptris.
    # The SDK now retains bibliography order; both the real parsed document
    # and explicitly absent order remain regression boundaries.
    let(:bsi_shaped) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="bsi">
          <bibdata>
            <docidentifier>BS 0</docidentifier>
            <ext><doctype>bsi</doctype></ext>
          </bibdata>
          <preface>
            <foreword id="fw"><p>fw</p></foreword>
          </preface>
          <sections>
            <clause type="scope" id="scope"><title>Scope</title></clause>
            <terms id="terms"><title>Terms</title></terms>
            <clause id="c1"><title>Body</title></clause>
          </sections>
          <bibliography>
            <references normative="true" id="nr"><title>Normative references</title></references>
            <clause id="bibl"><title>Bibliography</title>
              <references normative="false" id="b1"><title>Bibliography</title></references>
            </clause>
          </bibliography>
        </metanorma>
      XML
    end

    it "retains bibliography element order under the leptris adapter" do
      root = Lutaml::Model::AdapterScope.with(xml: :leptris) do
        Metanorma::IsoDocument::Root.from_xml(bsi_shaped)
      end
      expect(root.bibliography.element_order.map(&:name).select { |name| %w(references clause).include?(name) }).to eq(%w(references clause))
    end

    it "recognizes the ordered normative references without a false missing-tail finding" do
      ctx = Lutaml::Model::AdapterScope.with(xml: :leptris) do
        context_with(bsi_shaped)
      end
      issues = rule.check(ctx)
      expect(issues).to be_empty
    end
  end

  it "does not crash when a bibliography has explicitly absent order" do
    ctx = context_with('<metanorma xmlns="https://www.metanorma.org/ns/standoc"><bibliography><references normative="true"/></bibliography></metanorma>')
    ctx.root.bibliography.element_order = nil
    expect { rule.check(ctx) }.not_to raise_error
  end

  describe "code" do
    it "declares ISO_28 as default" do
      expect(described_class.new.code).to eq("ISO_28")
    end
  end
end
