require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleCaCfRule do
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

  it "flags ca. with the approximately suggestion" do
    issues = rule.check(context_with("a temperature of ca. 20 degrees"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("approximately")
  end

  it "flags c.f. with two periods but not cf." do
    issues = rule.check(context_with("see c.f. the standard, cf. also"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("c.f.")
  end

  it "passes for approximately and plain cf." do
    expect(rule.check(context_with(
      "approximately 20 degrees; cf. ISO 1"
    ))).to eq([])
  end
end
