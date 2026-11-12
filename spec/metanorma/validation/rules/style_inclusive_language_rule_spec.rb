require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleInclusiveLanguageRule do
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

  it "flags each listed non-inclusive term with its alternative" do
    term_to_alternative = {
      "manpower" => "personnel",
      "chairman" => "chair",
      "salesman" => "salesperson",
      "businessman" => "businessperson",
      "workman" => "worker",
      "foreman" => "supervisor",
      "manned" => "crewed",
      "master/slave" => "primary/secondary",
      "whitelist" => "allowlist",
      "blacklist" => "denylist",
      "dummy" => "placeholder",
    }
    term_to_alternative.each do |term, alternative|
      issues = rule.check(context_with("the #{term} applies here"))
      expect(issues.size).to eq(1), "expected '#{term}' to be flagged"
      expect(issues.first.code).to eq("ISO_96")
      expect(issues.first.message).to include(alternative)
    end
  end

  it "flags inflected forms of whitelist and blacklist" do
    ["whitelisted", "blacklisting"].each do |word|
      issues = rule.check(context_with("the entry is #{word}"))
      expect(issues.size).to eq(1), "expected '#{word}' to be flagged"
    end
  end

  it "does not flag 'unmanned'" do
    expect(rule.check(context_with(
      "an unmanned station operates automatically"
    ))).to eq([])
  end

  it "does not flag 'master' on its own" do
    expect(rule.check(context_with(
      "the master copy is archived"
    ))).to eq([])
  end

  it "does not flag the inclusive alternatives" do
    text = "the personnel chair the group using an allowlist and " \
           "a primary/secondary setup"
    expect(rule.check(context_with(text))).to eq([])
  end
end
