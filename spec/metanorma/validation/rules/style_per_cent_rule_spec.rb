require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StylePerCentRule do
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

  it "flags 'percent' as one word" do
    issues = rule.check(context_with("about 50 percent by mass"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_109")
    expect(issues.first.message).to include("per cent")
  end

  it "does not flag % usage or 'percentage'" do
    expect(rule.check(context_with(
      "a mass fraction of 50 % gives the percentage"
    ))).to eq([])
  end
end
