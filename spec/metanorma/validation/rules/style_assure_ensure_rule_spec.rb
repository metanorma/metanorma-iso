require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAssureEnsureRule do
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

  it "flags 'assure that' clauses" do
    %w[assure assures assured].each do |verb|
      issues = rule.check(context_with(
        "The checks #{verb} that the measurement is traceable."
      ))
      expect(issues.size).to eq(1), "expected '#{verb} that' flagged"
      expect(issues.first.code).to eq("ISO_71")
      expect(issues.first.message).to include("ensure")
    end
  end

  it "flags 'assure' with an inanimate article object" do
    issues = rule.check(context_with(
      "The procedures assure the integrity of the data."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("ensure")
  end

  it "flags 'assured' with data and quality nouns" do
    %w[data quality accuracy results performance values].each do |noun|
      issues = rule.check(context_with("The method has assured #{noun}."))
      expect(issues.size).to eq(1), "expected 'assured #{noun}' flagged"
    end
  end

  it "passes 'assure' with a personal object" do
    %w[user users reader customer operator public].each do |person|
      expect(rule.check(context_with(
        "The instructions assure the #{person} of safe operation."
      ))).to eq([]), "expected 'assure the #{person}' to pass"
    end
  end

  it "passes 'ensure' usage" do
    expect(rule.check(context_with(
      "The checks ensure that the measurement is traceable. " \
      "The procedures ensure the integrity of the data."
    ))).to eq([])
  end
end
