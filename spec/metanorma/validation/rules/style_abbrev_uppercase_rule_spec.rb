require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAbbrevUppercaseRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(*paragraphs)
    body = paragraphs.map { |t| "<p>#{t}</p>" }.join
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            #{body}
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags the lowercase instance of an uppercase abbreviation" do
    issues = rule.check(context_with(
      "the GPS receiver is used",
      "the gps receiver fails"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("gps")
  end

  it "flags within a single paragraph" do
    issues = rule.check(context_with("the ISO and iso standards differ"))
    expect(issues.size).to eq(1)
  end

  it "does not flag consistent casing" do
    expect(rule.check(context_with(
      "the GPS receiver and the ISO standard apply"
    ))).to eq([])
  end

  it "does not flag words without an uppercase counterpart" do
    expect(rule.check(context_with(
      "the valve assembly is delivered"
    ))).to eq([])
  end

  it "exempts the NOTE label from the casing comparison" do
    expect(rule.check(context_with(
      "NOTE applies to all items",
      "note that the valve is open"
    ))).to eq([])
  end

  it "exempts etc from the casing comparison" do
    expect(rule.check(context_with(
      "ETC valves, etc. are listed"
    ))).to eq([])
  end
end
