require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::SymbolsSectionCountRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml, vocab: false)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state_with_vocab = Metanorma::Iso::Validation::ConverterState.new(
      document: "spec", vocab: vocab
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state_with_vocab, shared: nil)
  end

  describe "#check" do
    it "passes when there are no definitions sections" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause id="c1"><title>X</title></clause></sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes with a single definitions section" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_25 with definitions in sections + annex (non-vocab)" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions>
          </sections>
          <annex id="a1"><title>A</title><definitions id="d2"><dl><dt>y</dt><dd>why</dd></dl></definitions></annex>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_25")
    end

    it "passes with two definitions sections in a vocab document" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions>
            <definitions id="d2"><dl><dt>y</dt><dd>why</dd></dl></definitions>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml, vocab: true))).to eq([])
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::SymbolsSectionContentRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "passes when definitions only has dl" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions></sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_26 when definitions contains a paragraph" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><definitions id="d1"><p>narrative</p></definitions></sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_26")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::SymbolsInAnnexRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec", vocab: true) }
  let(:rule) { described_class.new }

  def context_with(xml, vocab: true)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(document: "spec", vocab: vocab)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#check" do
    it "flags ISO_27 when vocab doc has definitions outside an annex" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml, vocab: true))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_27")
    end

    it "passes when vocab doc has definitions inside an annex" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>Body</title></clause>
          </sections>
          <annex id="a1"><title>Annex</title><definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions></annex>
        </metanorma>
      XML
      expect(rule.check(context_with(xml, vocab: true))).to eq([])
    end

    it "is not applicable for non-vocab documents" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><definitions id="d1"><dl><dt>x</dt><dd>ex</dd></dl></definitions></sections>
        </metanorma>
      XML
      context = context_with(xml, vocab: false)
      expect(rule).not_to be_applicable(context)
    end
  end
end
