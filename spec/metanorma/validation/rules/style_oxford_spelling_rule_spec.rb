require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleOxfordSpellingRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
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

  def paragraph(text)
    "<p>#{text}</p>"
  end

  it "flags -ise spellings of -ize verbs" do
    issues = rule.check(context_with(paragraph("we organise the data")))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_107")
    expect(issues.first.message).to include("use '-ize'")
  end

  it "flags -yse, -re, -our, -ogue and ll-doubling violations" do
    issues = rule.check(context_with(paragraph(
      "the analyzer at the center reads a liter from the catalog with " \
      "one color model, traveled once"
    )))
    expect(issues.size).to eq(5)
    expect(issues.map(&:message)).to include(
      /use '-yse'/, /use '-re'/, /use '-our'/, /use '-ogue'/, /double 'l'/
    )
  end

  it "flags defence, licence noun, programme, sulfur and other lists" do
    issues = rule.check(context_with(paragraph(
      "the defense of the license agreement uses program X with " \
      "sulphuric artifacts, focussed acknowledgments of aging and judgment"
    )))
    expect(issues.map(&:message)).to include(
      /defence/, /licence/, /programme/, /IUPAC/, /artefact/,
      /focused/, /acknowledgement/, /ageing/, /judgement/
    )
  end

  it "flags lowercase petri dishes" do
    issues = rule.check(context_with(paragraph("culture in petri dishes")))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("Petri dish")
  end

  it "flags lowercase petri dish singular" do
    issues = rule.check(context_with(paragraph("culture in a petri dish")))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("Petri dish")
  end

  it "exempts correct -ise verbs, computer program and meter" do
    expect(rule.check(context_with(paragraph(
      "we advertise the computer program; the meter reads a calibrated value"
    )))).to eq([])
  end

  it "does not lint math stem content" do
    body = "<p>see <stem type='AsciiMath'><asciimath>organised</asciimath>" \
           "</stem> prose organised here</p>"
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("use '-ize'")
  end
end
