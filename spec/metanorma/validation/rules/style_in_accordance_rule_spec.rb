require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleInAccordanceRule do
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

  it "flags 'according to' in a 'shall' sentence" do
    issues = rule.check(context_with(
      "The test shall be carried out according to ISO 12345."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("in accordance with")
  end

  it "flags 'according to' in a 'must not' sentence" do
    issues = rule.check(context_with(
      "Samples must not be stored according to the local practice."
    ))
    expect(issues.size).to eq(1)
  end

  it "flags 'according to' after an imperative start" do
    issues = rule.check(context_with(
      "Calibrate the apparatus according to the manufacturer's manual."
    ))
    expect(issues.size).to eq(1)
  end

  it "flags per requirement sentence, not per paragraph" do
    issues = rule.check(context_with(
      "The test shall be carried out according to ISO 12345. According " \
      "to the brochure, the device is portable. The report shall follow " \
      "the template according to ISO 690."
    ))
    expect(issues.size).to eq(2)
  end

  it "passes 'according to' in declarative sentences" do
    expect(rule.check(context_with(
      "According to the manufacturer, the apparatus has a drift of 1 %."
    ))).to eq([])
  end

  it "passes requirement sentences without 'according to'" do
    expect(rule.check(context_with(
      "The test shall be carried out in accordance with ISO 12345."
    ))).to eq([])
  end
end
