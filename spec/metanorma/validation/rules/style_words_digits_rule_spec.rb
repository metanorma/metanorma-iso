require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleWordsDigitsRule do
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

  it "flags standalone digits one to nine in prose" do
    issues = rule.check(context_with("The batch has 3 samples."))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("'3'")
    expect(issues.first.message).to include("words")
  end

  it "flags the brief's 'two of the 4 tests' case" do
    issues = rule.check(context_with("Two of the 4 tests failed."))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'4'")
  end

  it "flags each distinct digit once" do
    issues = rule.check(context_with("Use 2 plates and 5 covers."))
    expect(issues.size).to eq(2)
  end

  it "exempts digits with unit tokens" do
    expect(rule.check(context_with(
      "The sample is 3 mm thick, the run lasts 5 min, the load is 2 N " \
      "and the gap is 4mm wide."
    ))).to eq([])
  end

  it "exempts digits with spelled time quantities" do
    expect(rule.check(context_with(
      "The process takes 3 days, 2 hours and 5 weeks in total."
    ))).to eq([])
  end

  it "exempts digits in percent contexts" do
    expect(rule.check(context_with(
      "The fraction is 5 %, the share is 3 percent and the rest is 2 %."
    ))).to eq([])
  end

  it "exempts digits in comparisons and ranges" do
    expect(rule.check(context_with(
      "The committee counted 8 votes to 6, the ratio is 3 to 5 and the " \
      "range covers 4 to 7. Values from 2-5 apply."
    ))).to eq([])
  end

  it "exempts digits after reference tokens" do
    expect(rule.check(context_with(
      "See Clause 3, Table 4, Figure 5 and annex 6. Consult ISO 8 and " \
      "IEC 2 for details."
    ))).to eq([])
  end

  it "exempts letter-digit designations and part suffixes" do
    expect(rule.check(context_with(
      "Use M3 screws on an A4 sheet per part 2 of ISO 10303-1."
    ))).to eq([])
  end

  it "exempts dates and multi-digit numbers" do
    expect(rule.check(context_with(
      "The method dates from 3 January 2020; 12 samples were tested on " \
      "5 June."
    ))).to eq([])
  end

  it "exempts decimals and thousands separators" do
    expect(rule.check(context_with(
      "The thickness is 3.5 mm and the batch has 1,000 items."
    ))).to eq([])
  end

  it "exempts currency contexts" do
    expect(rule.check(context_with(
      "The fee is $3 per item, capped at 5 euros."
    ))).to eq([])
  end

  it "exempts sentence-start digits (StyleSentenceStartNumberRule's scope)" do
    expect(rule.check(context_with(
      "3 samples were tested today."
    ))).to eq([])
  end

  it "passes prose with numbers as words" do
    expect(rule.check(context_with(
      "The batch has three samples and four covers."
    ))).to eq([])
  end

  it "does not flag digits inside larger numbers or codes" do
    expect(rule.check(context_with(
      "Follow ISO 80000-1: use tolerance class 10 and grade 15."
    ))).to eq([])
  end
end
