require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ForewordStructureRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "passes for a flat foreword" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface><foreword id="fw"><p>Flat text</p></foreword></preface>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_23 when foreword has subclauses" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface><foreword id="fw"><clause><title>Sub</title></clause></foreword></preface>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_23")
    end
  end

  describe "code" do
    it "declares ISO_23" do
      expect(described_class.new.code).to eq("ISO_23")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::ScopeSubclausesRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "passes for a flat scope clause" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause type="scope" id="s"><title>Scope</title></clause></sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_39 when scope has subclauses" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause type="scope" id="s"><title>Scope</title><clause><title>Sub</title></clause></clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_39")
    end
  end

  describe "code" do
    it "declares ISO_39" do
      expect(described_class.new.code).to eq("ISO_39")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::OnlyChildClauseRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags ISO_43 when a clause has exactly one subclause" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="parent" type="scope"><title>Scope</title></clause>
            <clause id="c1"><title>Body</title><clause id="c2"><title>Lone</title></clause></clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_43")
    end

    it "passes when no clause has exactly one subclause" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <clause id="c2"><title>One</title></clause>
              <clause id="c3"><title>Two</title></clause>
            </clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_43" do
      expect(described_class.new.code).to eq("ISO_43")
    end
  end
end
