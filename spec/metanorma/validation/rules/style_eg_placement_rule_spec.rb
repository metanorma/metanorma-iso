require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleEgPlacementRule do
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

  it "flags running-text e.g." do
    issues = rule.check(context_with(
      "wireless devices, e.g. radios, are permitted"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_86")
    expect(issues.first.message).to include("for example")
  end

  it "flags running-text i.e." do
    issues = rule.check(context_with(
      "fast protocols, i.e. datagram-based ones, are preferred"
    ))
    expect(issues.size).to eq(1)
  end

  it "does not flag parenthesized e.g." do
    expect(rule.check(context_with(
      "wireless devices (e.g. radios) are permitted"
    ))).to eq([])
  end

  it "does not flag e.g. at the end of its sentence" do
    expect(rule.check(context_with(
      "consider wireless devices, e.g."
    ))).to eq([])
  end

  it "does not flag the words in full" do
    expect(rule.check(context_with(
      "for example, radios are permitted; that is the intent"
    ))).to eq([])
  end
end
