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
    expect(issues.first.code).to eq("ISO_66")
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

  # metanorma/metanorma-pdfa#118: a document whose only lowercase "iso"
  # sits inside a URL must not fire. The link's rendered text and any
  # bare URL in prose are both excluded from the scan.
  it "excludes URL text from the casing comparison" do
    expect(rule.check(context_with(
      "the ISO standard applies",
      "ISO documents are published at " \
      '<link target="https://www.iso.org">www.iso.org</link> today'
    ))).to eq([])
  end

  it "excludes bare URLs in prose from the casing comparison" do
    expect(rule.check(context_with(
      "the ISO standard applies",
      "ISO documents are published at https://www.iso.org and at " \
      "urn:iso:std:iso:1000"
    ))).to eq([])
  end

  it "excludes the flavor-injected boilerplate from both passes" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <boilerplate>
          <copyright-statement>
            <clause id="c0"><title>Copyright</title>
              <p>ISO copyright office. Website:
                <link target="https://www.iso.org">www.iso.org</link></p>
            </clause>
          </copyright-statement>
        </boilerplate>
        <sections>
          <clause id="c1"><title>One</title>
            <p>ISO documents are published widely.</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    ctx = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                  state: state, shared: nil)
    expect(rule.check(ctx)).to eq([])
  end

  it "still flags a lowercase instance in genuine prose" do
    issues = rule.check(context_with(
      "the ISO standard applies",
      "the iso standard fails"
    ))
    expect(issues.size).to eq(1)
  end
end
