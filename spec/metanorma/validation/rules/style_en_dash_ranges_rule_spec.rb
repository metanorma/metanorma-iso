require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleEnDashRangesRule do
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

  it "flags a closed-up number range with a unit" do
    issues = rule.check(context_with("a thickness of 5-10 mm is typical"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("10 mm to 20 mm")
    expect(issues.first.message).to include("5-10 mm")
  end

  it "flags an en dash range with a unit" do
    issues = rule.check(context_with("a mass of 100–200 kg is expected"))
    expect(issues.size).to eq(1)
  end

  it "flags a unit-on-both-sides range" do
    issues = rule.check(context_with("a length of 10 mm - 20 mm is normal"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("10 mm - 20 mm")
  end

  it "does not flag ranges already written with 'to'" do
    expect(rule.check(context_with(
      "a length of 10 mm to 20 mm is normal"
    ))).to eq([])
  end

  it "does not flag page ranges" do
    expect(rule.check(context_with(
      "see the examples on pp. 45-49"
    ))).to eq([])
  end

  it "does not flag date and year ranges (StyleDateDurationRule scope)" do
    text = "the session runs 10-15 March and the study covered 2020-2030"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "does not flag identifier hyphens" do
    text = "ISO 10303-11 and ISO 3166-1 alpha-2 are referenced"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "does not flag digit-grouped amounts" do
    expect(rule.check(context_with(
      "a mass of 1 000-2 000 kg is typical"
    ))).to eq([])
  end
end
