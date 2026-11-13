require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAcDcRfRule do
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

  it "flags a.c. and d.c." do
    issues = rule.check(context_with("an a.c. supply and a d.c. motor"))
    expect(issues.size).to eq(2)
    expect(issues.first.code).to eq("ISO_67")
    expect(issues.map(&:message)).to include(
      /'AC' as an adjective/, /'DC' as an adjective/
    )
  end

  it "flags obsolete r.f." do
    issues = rule.check(context_with("an r.f. signal"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("radio-frequency")
  end

  it "passes for AC, DC, RF and undotted full forms" do
    expect(rule.check(context_with(
      "the AC supply and the DC motor use alternating current and " \
      "direct current; the RF signal is an alternating one"
    ))).to eq([])
  end
end
