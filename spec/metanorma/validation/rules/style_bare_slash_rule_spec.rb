require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleBareSlashRule do
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

  it "flags a lowercase word/word slash with spaces" do
    issues = rule.check(context_with("the input / output values differ"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("input / output")
    expect(issues.first.message).to include("reword")
  end

  it "flags each spaced slash pair" do
    issues = rule.check(context_with("the start / stop and read / write paths"))
    expect(issues.size).to eq(2)
  end

  it "does not flag closed-up word/word forms" do
    ["input/output", "TCP/IP", "b/w", "I/O"].each do |fragment|
      expect(rule.check(context_with("the #{fragment} pair works"))).to eq([]),
        "expected '#{fragment}' not to be flagged"
    end
  end

  it "does not flag 'and / or' (reported by the ambiguous-words rule)" do
    expect(rule.check(context_with("cats and / or dogs"))).to eq([])
  end

  it "does not flag capitalized words around the slash" do
    expect(rule.check(context_with("the Input / Output stage"))).to eq([])
  end
end
