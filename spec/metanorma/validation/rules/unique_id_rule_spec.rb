require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::UniqueIdRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    shared = Metanorma::Iso::Validation::SharedState.new
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: shared)
  end

  describe "#check" do
    it "passes when all ids are unique" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>One</title></clause>
            <clause id="c2"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags STANDOC_36 for duplicate ids" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="dup"><title>One</title></clause>
            <clause id="dup"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("STANDOC_36")
    end

    it "populates SharedState with the id index" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>One</title></clause>
          </sections>
        </metanorma>
      XML
      context = context_with(xml)
      rule.check(context)
      expect(context.shared.doc_ids).to include("c1")
      expect(context.shared.id_seq).to include("c1")
    end
  end

  describe "code" do
    it "declares STANDOC_36" do
      expect(described_class.new.code).to eq("STANDOC_36")
    end
  end
end
