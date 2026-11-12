require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleThatWhichRule do
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

  it "flags comma-less 'which' after the House Style example nouns" do
    %w[those products documents samples].each do |noun|
      issues = rule.check(context_with(
        "All #{noun} which comply are listed in Table 2."
      ))
      expect(issues.size).to eq(1), "expected '#{noun} which' flagged"
      expect(issues.first.code).to eq("STANDOC_48")
      expect(issues.first.message).to include("that")
    end
  end

  it "flags ', that' non-defining clauses" do
    issues = rule.check(context_with(
      "The samples, that were contaminated, were discarded."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("which")
  end

  it "passes ', which' non-defining clauses" do
    expect(rule.check(context_with(
      "The samples, which were contaminated, were discarded."
    ))).to eq([])
  end

  it "passes defining 'that' clauses" do
    expect(rule.check(context_with(
      "The products that comply are listed in Table 2."
    ))).to eq([])
  end

  it "passes comma-preceded connectors before 'that'" do
    texts = [
      "Discard the sample, provided that the test has ended.",
      "Stir the mixture, so that the layers merge.",
      "The value is recorded, and that record is kept.",
      "The reading holds, given that the temperature is constant.",
      "The result differs, in that the method changed.",
      "The method is described, that is, in Clause 4."
    ]
    texts.each do |text|
      expect(rule.check(context_with(text))).to eq([]),
        "expected to pass: #{text.inspect}"
    end
  end

  it "passes comma-less 'which' after nouns outside the closed set" do
    expect(rule.check(context_with(
      "The machines which comply are listed in Table 2."
    ))).to eq([])
  end
end
