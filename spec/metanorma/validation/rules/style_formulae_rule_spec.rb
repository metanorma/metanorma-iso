require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleFormulaeRule do
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

  it "flags 'formulas'" do
    issues = rule.check(context_with("the formulas are given in Annex A"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("formulae")
  end

  it "is case-insensitive" do
    issues = rule.check(context_with("the Formulas below apply"))
    expect(issues.size).to eq(1)
  end

  it "does not flag 'formula' or 'formulae'" do
    text = "the formula applies to all formulae listed here"
    expect(rule.check(context_with(text))).to eq([])
  end
end
