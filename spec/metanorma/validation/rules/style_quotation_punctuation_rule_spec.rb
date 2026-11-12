require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleQuotationPunctuationRule do
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

  it "flags a full stop inside the quotes after a partial quotation" do
    issues = rule.check(context_with("the display shows &quot;standby.&quot;"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("outside")
  end

  it "flags the same pattern with typographic quotes" do
    issues = rule.check(context_with(
      "the display shows &#8220;standby.&#8221;"
    ))
    expect(issues.size).to eq(1)
  end

  it "does not flag the stop outside a partial quotation" do
    expect(rule.check(context_with(
      "the display shows &quot;standby&quot;."
    ))).to eq([])
  end

  it "does not flag a quoted complete sentence" do
    expect(rule.check(context_with(
      "Clause 5 states &quot;Test the device.&quot;"
    ))).to eq([])
  end

  it "does not flag quoted fragments without a trailing stop" do
    expect(rule.check(context_with(
      "the mode named &quot;standby&quot; is entered"
    ))).to eq([])
  end
end
