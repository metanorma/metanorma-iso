require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleFamilySuiteRule do
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

  it "flags family of standards" do
    issues = rule.check(context_with("this family of standards"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_89")
    expect(issues.first.message).to include("documents on [subject]")
  end

  it "flags suite of standards" do
    issues = rule.check(context_with("a suite of standards applies"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("developed by [committee]")
  end

  it "passes for ordinary use of family and suite" do
    expect(rule.check(context_with(
      "the suite of test cases and the family of parameters"
    ))).to eq([])
  end
end
