require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleContractionsRule do
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

  it "flags contractions with their full-form suggestion" do
    issues = rule.check(context_with("it's fine; don't wait; won't help"))
    expect(issues.size).to eq(3)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("use the full form")
    expect(issues.map(&:message)).to include(
      /it's/, /don't/, /won't/
    )
  end

  it "flags can't, isn't, we're and I'm forms" do
    issues = rule.check(context_with("the device can't start; it isn't on"))
    expect(issues.size).to eq(2)
    expect(issues.map(&:message)).to include(/can't/, /isn't/)
  end

  it "does not flag possessives" do
    expect(rule.check(context_with(
      "the system's response and the users' input"
    ))).to eq([])
  end
end
