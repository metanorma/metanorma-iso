require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleNoNosRule do
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

  it "flags the plural contraction 'nos.'" do
    issues = rule.check(context_with("see nos. 3 and 4"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("without the full stop")
  end

  it "flags the capitalized form 'Nos.'" do
    issues = rule.check(context_with("See Nos. 3 to 5 for details"))
    expect(issues.size).to eq(1)
  end

  it "does not flag the singular 'no.'" do
    expect(rule.check(context_with("see no. 3 for details"))).to eq([])
  end

  it "does not flag the plain plural 'nos'" do
    expect(rule.check(context_with("see nos 3 and 4 for details"))).to eq([])
  end

  it "does not flag the all-caps acronym 'NOS'" do
    expect(rule.check(context_with("the sensor reports NOS."))).to eq([])
  end
end
