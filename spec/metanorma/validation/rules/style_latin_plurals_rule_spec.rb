require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleLatinPluralsRule do
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

  it "flags each wrong Latin plural with its correct form" do
    wrong_to_right = {
      "criterias" => "criteria",
      "phenomenons" => "phenomena",
      "curriculums" => "curricula",
      "memorandums" => "memoranda",
      "millenniums" => "millennia",
      "spectrums" => "spectra",
      "stratums" => "strata",
      "crisises" => "crises",
      "addendums" => "addenda",
    }
    wrong_to_right.each do |wrong, right|
      issues = rule.check(context_with("the listed #{wrong} apply"))
      expect(issues.size).to eq(1), "expected '#{wrong}' to be flagged"
      expect(issues.first.code).to eq("ISO_100")
      expect(issues.first.message).to include(right)
    end
  end

  it "flags singular agreement of 'data'" do
    ["data is", "data was", "data has"].each do |phrase|
      issues = rule.check(context_with("the #{phrase} recorded here"))
      expect(issues.size).to eq(1), "expected '#{phrase}' to be flagged"
      expect(issues.first.message).to include("'data' is plural")
    end
  end

  it "does not flag possessive forms" do
    text = "the criteria's scope and the data's structure"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "does not flag 'metadata is'" do
    expect(rule.check(context_with("the metadata is complete"))).to eq([])
  end

  it "passes plural agreement of data and correct plurals" do
    text = "the data are recorded, the data were checked, " \
           "the criteria apply to the phenomena"
    expect(rule.check(context_with(text))).to eq([])
  end
end
