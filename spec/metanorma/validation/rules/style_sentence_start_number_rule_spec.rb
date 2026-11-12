require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleSentenceStartNumberRule do
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

  it "flags a sentence starting with a numeral" do
    issues = rule.check(context_with(
      "3 samples were tested at room temperature."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("'3'")
    expect(issues.first.message).to include("word")
  end

  it "flags only the numeral-initial sentence in a paragraph" do
    issues = rule.check(context_with(
      "The first batch is ready. 4 samples remain. The rest is archived."
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'4'")
  end

  it "flags a sentence starting with a year (House Style keeps flagging)" do
    issues = rule.check(context_with("2016 defines the reference method."))
    expect(issues.size).to eq(1)
  end

  it "passes label-style openings" do
    expect(rule.check(context_with(
      "3. Heat the sample to 105 °C. 5) Record the reading."
    ))).to eq([])
  end

  it "passes sentences starting with words" do
    expect(rule.check(context_with(
      "Three samples were tested. The rest were archived."
    ))).to eq([])
  end

  it "does not flag digits mid-sentence (StyleWordsDigitsRule's scope)" do
    expect(rule.check(context_with(
      "The batch holds 3 samples from group 4."
    ))).to eq([])
  end
end
