require "spec_helper"
require "unitsdb"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleCurrencySymbolsRule do
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

  it "flags a Unitsdb-recorded symbol before an amount" do
    issues = rule.check(context_with("a fee of €100 applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("ISO 4217")
    expect(issues.first.message).to include("USD 100")
    expect(issues.first.message).to include("currency symbol '€'")
  end

  it "flags other Unitsdb-recorded symbols" do
    fragments = ["€ 200", "£50", "¥300", "zł 10", "US$20"]
    fragments.each do |fragment|
      issues = rule.check(context_with("the amount #{fragment} is due"))
      expect(issues.size).to eq(1), "expected '#{fragment}' to be flagged"
    end
  end

  it "does not flag a symbol without an amount" do
    text = "the € sign is shown in column two"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "does not flag a bare dollar sign" do
    # Unitsdb records no bare "$" symbol presentation for USD (its
    # recorded presentation is "US$"); currencies without a recorded
    # symbol presentation flag nothing here — the currency CODE rules
    # cover the code-first policy.
    expect(rule.check(context_with("a fee of $100 applies"))).to eq([])
  end

  it "does not flag ISO 4217 codes" do
    expect(rule.check(context_with("a fee of USD 100 applies"))).to eq([])
  end

  it "does not flag stem content" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>the price <stem type="MathML">x &lt; €100</stem> is high</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    context = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                      state: state, shared: nil)
    expect(rule.check(context)).to eq([])
  end

  it "carries exactly Unitsdb's recorded symbol presentations" do
    expected = Unitsdb.database.currencies.flat_map do |currency|
      (currency.symbols || []).map(&:unicode)
    end.compact.uniq

    expect(described_class::CURRENCY_SYMBOLS).to match_array(expected)
    expect(described_class::CURRENCY_SYMBOLS)
      .to include("€", "£", "¥", "US$", "A$")
    expect(described_class::CURRENCY_SYMBOLS).not_to include("$")
  end

  it "produces identical findings across repeated scans" do
    # The Unitsdb-derived symbol set is built once per process: two
    # scans must yield the same findings.
    context = context_with("€ 200 and £50 are due")
    first = rule.check(context)
    second = rule.check(context)
    expect(first).not_to be_empty
    expect(second).to eq(first)
  end
end
