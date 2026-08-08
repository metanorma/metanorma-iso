require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ModalInClauseRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", document: "spec"
    )
  end
  let(:rule) { described_class.new }

  def context_with(body_xml)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        #{body_xml}
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags 'shall' in the Foreword" do
    body = "<preface><foreword id='fw'><p>The system shall comply.</p></foreword></preface>"
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("foreword")
    expect(issues.first.message).to include("requirement")
  end

  it "flags 'may' in the Scope clause" do
    body = <<-XML
      <sections>
        <clause type="scope" id="scope"><title>Scope</title>
          <p>This Standard may be applied broadly.</p>
        </clause>
      </sections>
    XML
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("permission")
  end

  it "passes for requirement language in main body clauses" do
    body = <<-XML
      <sections>
        <clause id="c1"><title>Body</title>
          <p>The system shall comply with all requirements.</p>
        </clause>
      </sections>
    XML
    expect(rule.check(context_with(body))).to eq([])
  end

  it "passes for non-modal text in the foreword" do
    body = "<preface><foreword id='fw'><p>This is a description.</p></foreword></preface>"
    expect(rule.check(context_with(body))).to eq([])
  end
end
