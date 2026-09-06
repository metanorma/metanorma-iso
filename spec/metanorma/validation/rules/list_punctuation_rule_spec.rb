require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ListPunctuationRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", document: "spec"
    )
  end
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

  it "passes when list is preceded by a colon" do
    body = "<p>Items are:</p><ul><li>a</li><li>b</li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "passes when list is preceded by a period" do
    body = "<p>The list follows.</p><ul><li>a</li><li>b</li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "flags STANDOC_48 when list is preceded by other text" do
    body = "<p>Items are; here</p><ul><li>a</li><li>b</li></ul>"
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("preceded by colon or full stop")
  end
end
