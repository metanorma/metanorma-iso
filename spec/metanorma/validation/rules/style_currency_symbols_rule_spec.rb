require "spec_helper"

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

  it "flags a dollar symbol before an amount" do
    issues = rule.check(context_with("a fee of $100 applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("ISO 4217")
    expect(issues.first.message).to include("USD 100")
  end

  it "flags other currency symbols" do
    ["€ 200", "£50", "¥300"].each do |fragment|
      issues = rule.check(context_with("the amount #{fragment} is due"))
      expect(issues.size).to eq(1), "expected '#{fragment}' to be flagged"
    end
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
            <p>the price <stem type="MathML">x &lt; $100</stem> is high</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    context = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                      state: state, shared: nil)
    expect(rule.check(context)).to eq([])
  end
end
