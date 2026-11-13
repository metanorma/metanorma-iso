require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleImpreciseRefsRule do
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

  it "flags the following clause and the preceding section" do
    issues = rule.check(context_with(
      "see the following clause and the preceding section"
    ))
    expect(issues.size).to eq(2)
    expect(issues.first.code).to eq("ISO_94")
    expect(issues.first.message).to include("cite the element")
  end

  it "flags the figure above and the table below" do
    issues = rule.check(context_with(
      "the dimensions are shown in the figure above; results appear in " \
      "the table below"
    ))
    expect(issues.size).to eq(2)
    expect(issues.map(&:message)).to all(include("identifier"))
  end

  it "passes for identified references" do
    expect(rule.check(context_with(
      "see Clause 5, Figure 3 and Table 2"
    ))).to eq([])
  end
end
