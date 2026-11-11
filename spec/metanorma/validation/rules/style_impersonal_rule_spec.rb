require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleImpersonalRule do
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

  it "flags we, our, you, your and I" do
    issues = rule.check(context_with(
      "you should check the data; we found our error; I defined your file"
    ))
    expect(issues.size).to eq(5)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("impersonal wording")
  end

  it "passes for impersonal text" do
    expect(rule.check(context_with(
      "the data are checked in accordance with the method"
    ))).to eq([])
  end
end
