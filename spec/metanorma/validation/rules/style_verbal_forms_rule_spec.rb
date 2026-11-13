require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleVerbalFormsRule do
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

  it "flags requirement-shaped 'will be'" do
    issues = rule.check(context_with("the device will be tested"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_118")
    expect(issues.first.message).to include("shall")
  end

  it "flags the closed-list continuations of 'will'" do
    ["will apply to all units", "will contain a label",
     "will consist of three parts", "will not be reused"].each do |text|
      issues = rule.check(context_with("the device #{text}"))
      expect(issues.size).to eq(1), "expected '#{text}' to be flagged"
    end
  end

  it "suggests shall in the message" do
    issues = rule.check(context_with("the mixture will consist of water"))
    expect(issues.first.message).to include("'will consist'")
  end

  it "does not flag 'shall'" do
    expect(rule.check(context_with(
      "the device shall be tested"
    ))).to eq([])
  end

  it "does not flag 'will' outside the closed continuation list" do
    expect(rule.check(context_with(
      "the next edition will address this topic"
    ))).to eq([])
  end

  it "does not flag the noun 'will'" do
    expect(rule.check(context_with(
      "the will of the parties governs"
    ))).to eq([])
  end
end
