require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleEmptyClauseRule do
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

  it "flags a clause with no content beyond its title" do
    issues = rule.check(context_with('<clause id="c1"><title>Empty</title></clause>'))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("empty clause")
    expect(issues.first.location).to eq("IsoClauseSection#c1")
  end

  it "flags a note-only clause" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Only a note</title>
        <note id="n1"><p>the note text</p></note>
      </clause>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("note-only")
  end

  it "flags an empty annex" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <annex id="a1"><title>Empty annex</title></annex>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    context = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                      state: state, shared: nil)
    issues = rule.check(context)
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("annexes")
  end

  it "does not flag a clause containing only subclauses" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Parent</title>
        <clause id="c1-1"><title>Child</title><p>content lives here</p></clause>
      </clause>
    BODY
    expect(issues).to eq([])
  end

  it "does not flag a clause with body content" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Full</title>
        <p>body text</p>
        <note id="n1"><p>a supporting note</p></note>
      </clause>
    BODY
    expect(issues).to eq([])
  end

  it "does not flag a clause containing a table" do
    issues = rule.check(context_with(<<~BODY))
      <clause id="c1"><title>Tabular</title>
        <table id="t1"><tbody><tr><td>x</td></tr></tbody></table>
      </clause>
    BODY
    expect(issues).to eq([])
  end
end
