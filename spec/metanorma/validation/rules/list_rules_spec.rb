require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ListCountRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "passes with at most one ordered list per clause" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <ol id="ol1"><li>x</li></ol>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end

  it "emits STANDOC_48 when clause has two ordered lists" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <ol id="ol1"><li>x</li></ol>
            <ol id="ol2"><li>y</li></ol>
          </clause>
        </sections>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("More than 1 ordered list")
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::ListDepthRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "passes for a shallow list" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <ul id="ul1"><li>x</li></ul>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end

  it "emits STANDOC_48 for a deeply nested list (>4 levels)" do
    deep_list = "<ul><li><ul><li><ul><li><ul><li><ul><li>deep</li></ul></li></ul></li></ul></li></ul></li></ul>"
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            #{deep_list}
          </clause>
        </sections>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("more than 4 levels")
  end
end
