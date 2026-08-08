require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAmbigWordsRule do
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

  it "flags 'and/or' usage" do
    issues = rule.check(context_with("cats and/or dogs"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
  end

  it "flags 'on-line' misspelling" do
    issues = rule.check(context_with("on-line service"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("on-line")
  end

  it "flags 'need to' ambiguous modal" do
    issues = rule.check(context_with("you need to comply"))
    expect(issues.size).to eq(1)
  end

  it "passes for clean text" do
    expect(rule.check(context_with("clean text with proper words"))).to eq([])
  end
end
