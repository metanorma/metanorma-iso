require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleNumberRule do
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

  it "flags decimal points in paragraph text" do
    issues = rule.check(context_with("the value 3.14 is pi"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("decimal point")
  end

  it "flags hyphen-minus before digits" do
    issues = rule.check(context_with("value is -42 here"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("minus sign")
  end

  it "passes for plain text without numbers" do
    expect(rule.check(context_with("no numbers here"))).to eq([])
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::StyleUnitsRule do
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

  it "flags missing space before %" do
    issues = rule.check(context_with("concentration is 50% by mass"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("space before %")
  end

  it "passes for properly spaced percent" do
    expect(rule.check(context_with("concentration is 50 % by mass"))).to eq([])
  end
end
