require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAbbrevTablesOnlyRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with_paragraph(text)
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

  def context_with_table(cell_text)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>Read the voltage values.</p>
            <table id="t1"><tbody><tr><td>#{cell_text}</td></tr></tbody></table>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags 'min.' in prose" do
    issues = rule.check(context_with_paragraph("a min. of 5 V applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_65")
    expect(issues.first.message).to include("in full")
  end

  it "flags 'max.' and 'lab.' in prose" do
    issues = rule.check(context_with_paragraph(
      "the max. value is recorded by the lab."
    ))
    expect(issues.size).to eq(2)
  end

  it "does not flag the words in full" do
    expect(rule.check(context_with_paragraph(
      "a minimum of 5 V applies"
    ))).to eq([])
  end

  it "does not flag the unit 'min' without a period" do
    expect(rule.check(context_with_paragraph(
      "heat for 5 min at 100 degrees"
    ))).to eq([])
  end

  it "does not flag table-cell content" do
    expect(rule.check(context_with_table("min. 5 V"))).to eq([])
  end
end
