require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StylePenultimateListRule do
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

  it "flags a penultimate ordered-list item ending with and" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>first item</li><li>second item and</li><li>third item</li></ol>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("penultimate list item ends with 'and'")
    expect(issues.first.message).to include("avoid ambiguity")
  end

  it "flags a penultimate unordered-list item ending with or before punctuation" do
    issues = rule.check(context_with(<<~BODY))
      <ul id="ul1"><li>alpha or</li><li>beta</li></ul>
    BODY
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("penultimate list item ends with 'or'")
  end

  it "flags a penultimate item whose conjunction precedes terminal punctuation" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>first item</li><li>second item, and.</li><li>third item</li></ol>
    BODY
    expect(issues.size).to eq(1)
  end

  it "does not flag conjunctions inside the item text" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>red and white</li><li>blue</li></ol>
    BODY
    expect(issues).to eq([])
  end

  it "does not flag a single-item list" do
    issues = rule.check(context_with('<ol id="ol1"><li>only item</li></ol>'))
    expect(issues).to eq([])
  end

  it "passes when the penultimate item omits the conjunction" do
    issues = rule.check(context_with(<<~BODY))
      <ol id="ol1"><li>first item</li><li>second item</li><li>third item</li></ol>
    BODY
    expect(issues).to eq([])
  end
end
