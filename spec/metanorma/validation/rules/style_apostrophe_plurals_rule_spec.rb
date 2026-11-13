require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleApostrophePluralsRule do
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

  it "flags the decade plural '1990's'" do
    issues = rule.check(context_with("data from the 1990's"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_70")
    expect(issues.first.message).to include("1990's")
  end

  it "flags a count-prefixed acronym plural" do
    issues = rule.check(context_with("a bank of three CPU's"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("CPU's")
  end

  it "flags digit-prefixed acronym plurals" do
    issues = rule.check(context_with("an array of 4 GPU's"))
    expect(issues.size).to eq(1)
  end

  it "does not flag the correct decade plural" do
    expect(rule.check(context_with(
      "data from the 1990s"
    ))).to eq([])
  end

  it "does not flag possessive acronyms without a count" do
    expect(rule.check(context_with(
      "the CPU's registers are cleared"
    ))).to eq([])
  end

  it "does not flag single-digit possessives" do
    expect(rule.check(context_with(
      "step 5's caption is omitted"
    ))).to eq([])
  end
end
