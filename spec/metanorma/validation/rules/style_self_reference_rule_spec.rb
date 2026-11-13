require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleSelfReferenceRule do
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

  it "flags this International Standard and this Standard" do
    issues = rule.check(context_with(
      "this International Standard applies; this Standard applies"
    ))
    expect(issues.size).to eq(2)
    expect(issues.first.code).to eq("ISO_113")
    expect(issues.map(&:message)).to all(include("this document"))
  end

  it "flags this part of ISO" do
    issues = rule.check(context_with("this part of ISO 1234 applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("this document")
  end

  it "passes for this document" do
    expect(rule.check(context_with(
      "this document specifies the method"
    ))).to eq([])
  end
end
