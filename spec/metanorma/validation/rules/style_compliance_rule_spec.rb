require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleComplianceRule do
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

  it "flags compliance with the legislation reservation in the message" do
    issues = rule.check(context_with("the compliance of the sample"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("reserves 'compliance'")
    expect(issues.first.message).to include("conformity")
  end

  it "flags compliant and non-compliant forms" do
    issues = rule.check(context_with(
      "a compliant device; non-compliant results; noncompliance"
    ))
    expect(issues.size).to eq(3)
    expect(issues.map(&:message)).to all(include("conforming"))
  end

  it "passes for conformity and conforming" do
    expect(rule.check(context_with(
      "conformity with this document; conforming samples"
    ))).to eq([])
  end
end
