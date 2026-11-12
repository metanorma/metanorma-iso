# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleDecimalCommaRule do
  let(:rule) { described_class.new }

  def context_with(text, lang: "de")
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <language>#{lang}</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p>#{text}</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(
      document: "spec", lang: lang
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags a paragraph mixing list commas and decimal commas" do
    issues = rule.check(context_with("1, 2, 0,01 mm and 5,25 mm"))
    expect(issues.map(&:code)).to all(eq("ISO_143"))
    expect(issues.size).to eq(2)
    expect(issues.map(&:message)).to include(
      a_string_including("0,01", "number:0,01[]"),
      a_string_including("5,25", "number:0,01[]"),
    )
  end

  it "carries the policy citation on the flagged message" do
    issues = rule.check(context_with("1, 2, 0,01 mm"))
    expect(issues.first.message).to include("ISO House Style")
  end

  it "passes a paragraph whose only commas are decimal commas" do
    expect(rule.check(context_with("the diameter is 3,5 mm"))).to eq([])
  end

  it "passes a comma-decimal paragraph with list commas but no digit-comma-digit" do
    expect(rule.check(context_with("see ISO 1, ISO 2 and ISO 3"))).to eq([])
  end

  it "passes a point-decimal locale document" do
    # English renders decimal points: the digit-comma-digit ambiguity
    # cannot arise, so the rule stays silent even on the same shape.
    issues = rule.check(context_with("1, 2, 0.01 mm and 5.25 mm", lang: "en"))
    expect(issues).to eq([])
  end

  it "resolves region variants of a comma-decimal language" do
    issues = rule.check(context_with("1, 2, 0,01 mm", lang: "fr-FR"))
    expect(issues.size).to eq(1)
  end

  it "flags each distinct ambiguous occurrence once" do
    issues = rule.check(context_with("0,05 mm, 0,05 mm and 0,15 mm"))
    expect(issues.size).to eq(2)
  end
end
