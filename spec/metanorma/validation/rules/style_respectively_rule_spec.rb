require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleRespectivelyRule do
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

  it "flags 'respectively' without a paired enumeration in the sentence" do
    issues = rule.check(context_with(
      "The values were measured respectively recorded."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_112")
    expect(issues.first.message).to include("respectively")
  end

  it "flags each offending sentence separately" do
    issues = rule.check(context_with(
      "The masses were recorded respectively. The volumes follow " \
      "respectively."
    ))
    expect(issues.size).to eq(2)
  end

  it "passes 'respectively' with a comma-list" do
    expect(rule.check(context_with(
      "Masses and volumes, in grams and millilitres respectively, are given."
    ))).to eq([])
  end

  it "passes 'respectively' with an and/or enumeration" do
    texts = [
      "The masses and volumes are given in grams and millilitres " \
        "respectively.",
      "Masses or volumes are given respectively."
    ]
    texts.each do |text|
      expect(rule.check(context_with(text))).to eq([]),
        "expected to pass: #{text.inspect}"
    end
  end

  it "passes sentences without 'respectively'" do
    expect(rule.check(context_with(
      "The values were measured and recorded."
    ))).to eq([])
  end
end
