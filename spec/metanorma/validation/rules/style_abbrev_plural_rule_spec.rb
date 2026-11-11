require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleAbbrevPluralRule do
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

  it "flags the doubled-s plural 'MSSs'" do
    issues = rule.check(context_with("all MSSs are listed"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("invariant")
  end

  it "does not flag the singular 'MSS'" do
    expect(rule.check(context_with("the MSS is listed"))).to eq([])
  end

  it "does not flag other spellings" do
    ["MSs", "MSS", "MSSS"].each do |word|
      expect(rule.check(context_with("the #{word} applies"))).to eq([]),
        "expected '#{word}' not to be flagged"
    end
  end
end
