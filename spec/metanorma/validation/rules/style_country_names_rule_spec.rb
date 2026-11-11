require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleCountryNamesRule do
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

  it "flags North Korea" do
    issues = rule.check(context_with("delegation from North Korea"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message)
      .to include("Democratic People's Republic of Korea")
  end

  it "flags South Korea, Russia and Vietnam" do
    issues = rule.check(context_with(
      "trade between South Korea, Russia and Vietnam"
    ))
    expect(issues.size).to eq(3)
    expect(issues.map(&:message)).to include(
      /Republic of Korea/, /Russian Federation/, /Viet Nam/
    )
  end

  it "does not flag UK, US or derived forms" do
    expect(rule.check(context_with(
      "the US and UK delegations, Russian exports and Vietnamese goods"
    ))).to eq([])
  end
end
