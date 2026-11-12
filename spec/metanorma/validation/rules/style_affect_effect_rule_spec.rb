require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAffectEffectRule do
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

  it "flags 'effect(s)' as a verb of influence before the result" do
    %w[effect effects].each do |verb|
      issues = rule.check(context_with(
        "This #{verb} the result of the test."
      ))
      expect(issues.size).to eq(1), "expected '#{verb} the result' flagged"
      expect(issues.first.code).to eq("STANDOC_48")
      expect(issues.first.message).to include("affect")
    end
  end

  it "flags 'effect(s) the performance/value/measurement' forms" do
    %w[performance value measurement].each do |noun|
      issues = rule.check(context_with("This effects the #{noun} strongly."))
      expect(issues.size).to eq(1), "expected 'effects the #{noun}' flagged"
    end
  end

  it "flags 'affect' used as a noun" do
    %w[the a an].each do |article|
      issues = rule.check(context_with(
        "The test studies #{article} affect of temperature."
      ))
      expect(issues.size).to eq(1), "expected '#{article} affect' flagged"
      expect(issues.first.message).to include("effect")
    end
  end

  it "passes correct 'affects' verb usage" do
    expect(rule.check(context_with(
      "Temperature affects the result."
    ))).to eq([])
  end

  it "passes correct 'effect' noun usage" do
    expect(rule.check(context_with(
      "The effect of temperature on the result is small. " \
      "The side effects are known."
    ))).to eq([])
  end

  it "passes the legitimate verbal 'effect changes'" do
    expect(rule.check(context_with(
      "The change effects cost savings." # "bring about" — not influence
    ))).to eq([])
  end
end
