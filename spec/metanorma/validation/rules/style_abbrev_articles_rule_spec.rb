require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAbbrevArticlesRule do
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

  it "flags 'a' before letter-pronounced initialisms" do
    %w[GPS UN URN ERP HR SQL API ISO HTML XML RGB RPG SAP PDF JPG
       RPM RSA SLA UML URL].each do |initialism|
      issues = rule.check(context_with("uses a #{initialism} reference"))
      expect(issues.size).to eq(1), "expected 'a #{initialism}' to be flagged"
      expect(issues.first.code).to eq("ISO_63")
      expect(issues.first.message).to include("an")
    end
  end

  it "does not flag 'an' before the same initialisms" do
    text = "an XML file, an SQL database, and an ISO standard"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "does not flag word-pronounced acronyms" do
    expect(rule.check(context_with(
      "a NATO body and a RAM chip"
    ))).to eq([])
  end

  it "does not flag lowercase spellings" do
    expect(rule.check(context_with(
      "a gps receiver is used"
    ))).to eq([])
  end
end
