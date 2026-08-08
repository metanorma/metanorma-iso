require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ScopePresenceRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags ISO_29 when sections has no scope clause" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause id="c1"><title>Other</title></clause></sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_29")
      expect(issues.first.message).to include("Scope clause missing")
    end

    it "passes when sections has a scope clause" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause type="scope" id="scope"><title>Scope</title></clause></sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_29" do
      expect(described_class.new.code).to eq("ISO_29")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::NormativeReferencesPresenceRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags ISO_30 when bibliography has no normative references" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <bibliography><references normative="false"><title>Bib</title></references></bibliography>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_30")
    end

    it "passes when bibliography has a normative references section" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <bibliography><references normative="true"><title>Norm Refs</title></references></bibliography>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_30" do
      expect(described_class.new.code).to eq("ISO_30")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::TermsPresenceRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec", amd: false) }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags ISO_31 when sections has no terms" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause id="c1"><title>X</title></clause></sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_31")
    end

    it "passes when sections has terms" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>Scope</title></clause>
            <terms id="t1"><title>Terms</title></terms>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_31" do
      expect(described_class.new.code).to eq("ISO_31")
    end
  end
end
