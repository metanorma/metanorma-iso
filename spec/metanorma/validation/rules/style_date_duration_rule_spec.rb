require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleDateDurationRule do
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

  it "flags a hyphenated day range before a month" do
    issues = rule.check(context_with("the session runs 10-15 March"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("use 'to'")
  end

  it "flags a hyphenated year range" do
    issues = rule.check(context_with("the study covered 2020-2030"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("2020 to 2030")
  end

  it "flags an en dash year range" do
    issues = rule.check(context_with("the study covered 2020–2030"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("year range")
  end

  it "flags a hyphenated century range" do
    issues = rule.check(context_with("the manuscripts date from the 18th-19th centuries"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("century range")
  end

  it "flags a digit century and asks for words" do
    issues = rule.check(context_with("standards from the 20th century"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("century in words")
  end

  it "does not flag closed-up page ranges" do
    expect(rule.check(context_with("see the tables on pp. 45-49"))).to eq([])
  end

  it "does not flag measurement ranges without a date context" do
    expect(rule.check(context_with("a tolerance of 1-2 mm applies"))).to eq([])
  end

  it "passes ranges already written with 'to'" do
    text = "the session runs 10 to 15 March, the study 2020 to 2030, " \
           "and the sources are from the eighteenth to nineteenth centuries"
    expect(rule.check(context_with(text))).to eq([])
  end

  it "passes the spelled-out century" do
    expect(rule.check(context_with("standards from the twentieth century"))).to eq([])
  end
end
