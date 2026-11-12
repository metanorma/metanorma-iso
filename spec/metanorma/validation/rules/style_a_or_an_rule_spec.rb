require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAOrAnRule do
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

  it "flags 'a' before vowel-sound words" do
    %w[hour hourly honest honesty honor honour heir].each do |word|
      issues = rule.check(context_with("It takes a #{word} to finish."))
      expect(issues.size).to eq(1), "expected 'a #{word}' flagged"
      expect(issues.first.code).to eq("STANDOC_48")
      expect(issues.first.message).to include("'an'")
    end
  end

  it "flags 'an' before consonant-sound words" do
    %w[European user unique university unit union uniform EULA].each do |word|
      issues = rule.check(context_with("It is an #{word} document."))
      expect(issues.size).to eq(1), "expected 'an #{word}' flagged"
      expect(issues.first.message).to include("'a'")
    end
  end

  it "flags 'an one-...' compounds" do
    issues = rule.check(context_with("It is an one-dimensional model."))
    expect(issues.size).to eq(1)
  end

  it "passes correct 'an hour' usage" do
    expect(rule.check(context_with(
      "It takes an hour, an honest answer and an heir."
    ))).to eq([])
  end

  it "passes correct 'a European' usage" do
    expect(rule.check(context_with(
      "a European body, a user, a unique case, a university, a unit, " \
      "a uniform, a EULA and a one-dimensional model"
    ))).to eq([])
  end

  it "does not flag initialisms (StyleAbbrevArticlesRule's scope)" do
    expect(rule.check(context_with(
      "a GPS receiver, an ISO standard, an XML file and a UN mandate"
    ))).to eq([])
  end
end
