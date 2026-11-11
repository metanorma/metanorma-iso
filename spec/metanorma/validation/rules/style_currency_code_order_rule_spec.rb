require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleCurrencyCodeOrderRule do
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

  it "flags an amount written before its ISO 4217 code" do
    issues = rule.check(context_with("a fee of 100 USD applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("USD 100")
    expect(issues.first.message).not_to include("not 'USD 100'")
  end

  it "flags a decimal amount before its code" do
    issues = rule.check(context_with("a fee of 1 500.50 EUR applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("EUR 500.50")
  end

  it "flags each amount-before-code occurrence" do
    issues = rule.check(context_with("paid 100 USD and 50 GBP"))
    expect(issues.size).to eq(2)
  end

  it "does not flag code-first amounts" do
    expect(rule.check(context_with("a fee of USD 100 applies"))).to eq([])
  end

  it "does not flag year-qualified codes" do
    expect(rule.check(context_with(
      "expressed in 2026 USD terms"
    ))).to eq([])
  end

  it "does not flag unknown uppercase words after numbers" do
    expect(rule.check(context_with(
      "the test used 3 API endpoints"
    ))).to eq([])
  end
end
