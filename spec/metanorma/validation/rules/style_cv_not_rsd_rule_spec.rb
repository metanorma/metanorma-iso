require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleCvNotRsdRule do
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

  it "flags relative standard deviation" do
    issues = rule.check(context_with("the relative standard deviation"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("coefficient of variation")
  end

  it "flags the standalone RSD acronym" do
    issues = rule.check(context_with("the RSD is small"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("coefficient of variation")
  end

  it "passes for coefficient of variation" do
    expect(rule.check(context_with(
      "the coefficient of variation (Cv) is small"
    ))).to eq([])
  end
end
