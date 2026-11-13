require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleFewerLessRule do
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

  it "flags 'less' with a count noun" do
    %w[samples tests results measurements items products].each do |noun|
      issues = rule.check(context_with("The batch has less #{noun} today."))
      expect(issues.size).to eq(1), "expected 'less #{noun}' flagged"
      expect(issues.first.code).to eq("ISO_90")
      expect(issues.first.message).to include("fewer")
    end
  end

  it "flags 'less than N' with a count noun" do
    issues = rule.check(context_with(
      "Less than 10 samples were rejected."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("fewer than")
  end

  it "flags 'less than N' with a count noun only once" do
    issues = rule.check(context_with("Less than 10 samples failed."))
    expect(issues.size).to eq(1)
  end

  it "passes 'less than' with bare quantities and units" do
    expect(rule.check(context_with(
      "The run takes less than 10 min. The load is less than 5 N. " \
      "Use less than 50 % of the capacity."
    ))).to eq([])
  end

  it "passes 'less' with uncountables" do
    expect(rule.check(context_with(
      "Less time is needed. Less equipment is used. Less money is spent."
    ))).to eq([])
  end

  it "passes 'fewer' usage" do
    expect(rule.check(context_with(
      "Fewer samples are tested this year."
    ))).to eq([])
  end
end
