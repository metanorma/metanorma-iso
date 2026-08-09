require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::BrokenXrefRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags STANDOC_38 when xref target does not exist" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>see <xref target="nonexistent">bogus</xref></p>
          </clause>
        </sections>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_38")
    expect(issues.first.message).to include("nonexistent")
  end

  it "passes when xref target exists as an id" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>see <xref target="c1">self</xref></p>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end

  it "passes when xref target exists as an anchor" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1" anchor="myanchor"><title>One</title>
            <p>see <xref target="myanchor">anchor</xref></p>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end
end
