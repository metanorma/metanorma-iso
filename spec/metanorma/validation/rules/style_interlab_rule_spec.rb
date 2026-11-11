require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleInterlabRule do
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

  it "flags round robin" do
    issues = rule.check(context_with("run a round robin test"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message)
      .to include("interlaboratory comparison")
  end

  it "flags ring test" do
    issues = rule.check(context_with("perform a ring test"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("interlaboratory comparison")
  end

  it "passes for interlaboratory comparison" do
    expect(rule.check(context_with(
      "an interlaboratory comparison was carried out"
    ))).to eq([])
  end
end
