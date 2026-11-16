require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleInformativeNormativeRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(text)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>#{text}</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags 'informative Annex B' in text" do
    issues = rule.check(context_with("see the informative Annex B"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_97")
    expect(issues.first.message).to include("informative Annex B")
  end

  it "flags 'normative clause 4' in text" do
    issues = rule.check(context_with("the requirements of normative clause 4 apply"))
    expect(issues.size).to eq(1)
  end

  it "does not flag the parenthetical designator" do
    expect(rule.check(context_with(
      "see Annex B (informative) for guidance"
    ))).to eq([])
  end

  it "does not flag the predicative form" do
    expect(rule.check(context_with(
      "Annex B is informative"
    ))).to eq([])
  end

  it "does not flag plain cross-references" do
    expect(rule.check(context_with(
      "see Annex B and Table 3 for details"
    ))).to eq([])
  end
end
