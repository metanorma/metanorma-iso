require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::UnreferencedAssetsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags ISO_21 for unreferenced annex" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections><clause id="c1"><title>Body</title></clause></sections>
        <annex id="a1" anchor="annexA"><title>Annex</title></annex>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    annex_issues = issues.select { |i| i.code == "ISO_21" && i.params.include?("Annex") }
    expect(annex_issues.size).to eq(1)
  end

  it "passes when annex is referenced via xref" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <xref target="annexA">Annex A</xref></p>
          </clause>
        </sections>
        <annex id="a1" anchor="annexA"><title>Annex</title></annex>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.select { |i| i.params.include?("Annex") }).to eq([])
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::LocalityErefsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags ISO_49 for undated ISO eref with locality" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <eref citeas="ISO 1234" bibitemid="iso1234"><localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack></eref></p>
          </clause>
        </sections>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_49")
  end

  it "passes for undated ISO eref without locality" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <eref citeas="ISO 1234" bibitemid="iso1234"/></p>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end
end
