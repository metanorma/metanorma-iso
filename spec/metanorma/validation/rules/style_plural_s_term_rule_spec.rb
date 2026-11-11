require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StylePluralSTermRule do
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

  it "flags the (s) pluralization" do
    issues = rule.check(context_with("sample(s) of material"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("one or more")
  end

  it "does not flag a standalone (s) marker" do
    expect(rule.check(context_with(
      "the marker (s) denotes the solid phase"
    ))).to eq([])
  end
end
