require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleNestedParensRule do
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

  it "flags nested parentheses" do
    issues = rule.check(context_with("the value (first (second) inner) matters"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_102")
    expect(issues.first.message).to include("nested parentheses")
    expect(issues.first.message).to include("square brackets")
  end

  it "advises when a sentence carries more than two parenthetical sets" do
    issues = rule.check(context_with("(a) the first set (b) the second set (c) the third set"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("more than 2 parenthetical sets")
  end

  it "passes with at most two parenthetical sets" do
    issues = rule.check(context_with("(a) the first set (b) the second set"))
    expect(issues).to eq([])
  end

  it "passes with two separate parenthetical sentences" do
    issues = rule.check(context_with("(a) one point here. (b) another point here."))
    expect(issues).to eq([])
  end

  it "reports both findings when nesting and an over-long sentence coincide" do
    issues = rule.check(context_with("(a) set one (b) set two (c) set three (see (also) note)"))
    messages = issues.map(&:message)
    expect(messages.count { |m| m.include?("nested parentheses") }).to eq(1)
    expect(messages.count { |m| m.include?("parenthetical sets") }).to eq(1)
  end
end
