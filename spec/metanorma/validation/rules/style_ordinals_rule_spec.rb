require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleOrdinalsRule do
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

  it "flags firstly, secondly and thirdly" do
    issues = rule.check(context_with(
      "firstly measure, secondly record, thirdly report"
    ))
    expect(issues.size).to eq(3)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message)
      .to include("use 'first', 'second', 'third'")
  end

  it "passes for ordinal adjectives" do
    expect(rule.check(context_with(
      "the first step is the second attempt"
    ))).to eq([])
  end
end
