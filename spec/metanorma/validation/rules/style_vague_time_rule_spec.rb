require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleVagueTimeRule do
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

  it "flags each vague time reference" do
    {
      "last year" => "last year",
      "recently" => "recently",
      "lately" => "lately",
      "in the past" => "in the past",
    }.each do |phrase, label|
      issues = rule.check(context_with("the method was revised #{phrase}"))
      expect(issues.size).to eq(1), "expected '#{phrase}' to be flagged"
      expect(issues.first.code).to eq("ISO_117")
      expect(issues.first.message).to include(label)
      expect(issues.first.message).to include("actual date")
    end
  end

  it "flags sentence-initial 'Recently'" do
    issues = rule.check(context_with("Recently the method was revised"))
    expect(issues.size).to eq(1)
  end

  it "does not flag dated statements" do
    text = "the method was revised in 2024 and in March 2026"
    expect(rule.check(context_with(text))).to eq([])
  end
end
