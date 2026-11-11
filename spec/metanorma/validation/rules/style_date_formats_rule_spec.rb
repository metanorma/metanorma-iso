require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleDateFormatsRule do
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

  it "flags an ordinal suffix before a month name" do
    issues = rule.check(context_with("adopted on 31st October 2026"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("ordinal date suffix")
  end

  it "flags the ordinal form with 'of'" do
    issues = rule.check(context_with("the revision of the 3rd of October"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("ordinal date suffix")
  end

  it "flags an ordinal suffix after a month name without double-flagging US order" do
    issues = rule.check(context_with("the deadline is March 3rd, 2026"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("ordinal date suffix")
  end

  it "flags month-first (US) date order with a comma" do
    issues = rule.check(context_with("published on October 31, 2026"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("month-first date order")
  end

  it "flags abbreviated month-first order without a comma" do
    issues = rule.check(context_with("effective from Oct 31 2026"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("month-first date order")
  end

  it "passes the day-month-year form" do
    expect(rule.check(context_with("adopted on 31 October 2026"))).to eq([])
  end

  it "passes a bare month-year mention" do
    expect(rule.check(context_with("in October 2026 the group met"))).to eq([])
  end

  it "passes dates without ordinal suffixes in other contexts" do
    expect(rule.check(context_with("the 2nd column of the table"))).to eq([])
  end
end
