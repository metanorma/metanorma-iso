require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleMixedListsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(body)
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

  it "flags an ordered list nested in an unordered list" do
    issues = rule.check(context_with(<<~BODY))
      <ul id="ul1"><li>outer
        <ol id="ol1"><li>inner</li></ol>
      </li></ul>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_101")
    expect(issues.first.message).to include("ordered list nested in unordered list")
  end

  it "flags an unordered list nested in an ordered list" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>outer
        <ul id="ul1"><li>inner</li></ul>
      </li></ol>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("unordered list nested in ordered list")
  end

  it "passes same-type nesting" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>outer
        <ol id="ol2"><li>inner</li></ol>
      </li></ol>
      <ul id="ul1"><li>outer
        <ul id="ul2"><li>inner</li></ul>
      </li></ul>
    BODY
    expect(issues).to eq([])
  end

  it "passes flat lists" do
    issues = rule.check(context_with(<<~BODY))
      <ul id="ul1"><li>alpha</li></ul>
      <ol id="ol1"><li>one</li></ol>
    BODY
    expect(issues).to eq([])
  end
end
