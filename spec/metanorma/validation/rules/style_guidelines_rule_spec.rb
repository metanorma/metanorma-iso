require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleGuidelinesRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(body)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          #{body}
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags 'guidelines' in a clause title" do
    issues = rule.check(context_with(
      '<clause id="c1"><title>Guidelines for measurement</title>' \
      "<p>body prose may mention guidelines freely</p></clause>"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.location).to eq("IsoClauseSection#c1")
    expect(issues.first.message).to include("guidance")
  end

  it "flags 'guidelines' in a subclause title" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>General</title>
        <clause id="c1-1"><title>Safety guidelines</title><p>text</p></clause>
      </clause>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.location).to eq("IsoClauseSection#c1-1")
  end

  it "flags 'guidelines' in an annex title" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <annex id="a1"><title>Guidelines for use</title><p>text</p></annex>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    context = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                      state: state, shared: nil)
    issues = rule.check(context)
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("title style")
  end

  it "flags 'guidelines' in a table caption" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Tabular</title>
        <table id="t1"><name>Guidelines for data entry</name>
          <tbody><tr><td>x</td></tr></tbody>
        </table>
      </clause>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("caption style")
  end

  it "flags 'guidelines' in a figure caption" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Figures</title>
        <figure id="f1"><name>Sampling guidelines</name></figure>
      </clause>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("caption style")
  end

  it "does not flag body prose or 'guidance' titles" do
    issues = rule.check(context_with(
      '<clause id="c1"><title>Guidance for measurement</title>' \
      "<p>this clause gives guidelines for measurement</p></clause>"
    ))
    expect(issues).to eq([])
  end
end
