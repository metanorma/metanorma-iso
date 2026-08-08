require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TitleFirstLevelRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "passes when all first-level subclauses have titles" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="parent" type="scope"><title>Parent</title></clause>
            <clause id="c1"><title>One</title></clause>
            <clause id="c2"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_19 for first-level subclause without title" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="parent" type="scope"><title>Parent</title></clause>
            <clause id="c1"><title>One</title></clause>
            <clause id="c2"></clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_19")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::TitleSiblingsConsistencyRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "passes when all siblings have titles" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="parent" type="scope"><title>Parent</title></clause>
            <clause id="c1"><title>One</title></clause>
            <clause id="c2"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_20 when siblings have inconsistent titling" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="parent" type="scope"><title>Parent</title>
              <clause id="c1"><title>One</title></clause>
              <clause id="c2"></clause>
            </clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_20")
    end
  end
end
