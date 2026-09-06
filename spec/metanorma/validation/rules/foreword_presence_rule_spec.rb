require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ForewordPresenceRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags when preface has no foreword" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface/>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
    end

    it "passes when preface has a foreword" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface><foreword id="fw"><p>x</p></foreword></preface>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end
end
