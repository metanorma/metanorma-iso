require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleNoBoxesRule do
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

  it "flags an admonition box" do
    issues = rule.check(context_with(
      '<admonition id="box1" type="box"><p>boxed content</p></admonition>'
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_103")
    expect(issues.first.location).to eq("AdmonitionBlock#box1")
    expect(issues.first.message).to include("cannot be cross-referenced")
  end

  it "flags every admonition type except note" do
    issues = rule.check(context_with(<<~BODY))
      <admonition id="b1" type="caution"><p>caution text</p></admonition>
      <admonition id="b2" type="warning"><p>warning text</p></admonition>
      <admonition id="b3" type="note"><p>note text</p></admonition>
    BODY
    expect(issues.size).to eq(2)
    expect(issues.map(&:location)).to contain_exactly(
      "AdmonitionBlock#b1", "AdmonitionBlock#b2"
    )
  end

  it "does not flag note elements" do
    issues = rule.check(context_with(
      '<note id="n1"><p>the note text</p></note>'
    ))
    expect(issues).to eq([])
  end

  it "does not flag example elements" do
    issues = rule.check(context_with(
      '<example id="e1"><p>the example text</p></example>'
    ))
    expect(issues).to eq([])
  end
end
