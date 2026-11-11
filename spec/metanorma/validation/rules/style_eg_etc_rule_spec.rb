require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleEgEtcRule do
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

  it "flags e.g. and etc. in the same sentence" do
    issues = rule.check(context_with("use e.g. red, blue, etc."))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("same sentence")
  end

  it "flags a comma after e.g. or i.e." do
    issues = rule.check(context_with("e.g., red and i.e., blue"))
    expect(issues.size).to eq(2)
    expect(issues.first.message).to include("no comma follows")
  end

  it "passes when e.g. and etc. sit in different sentences" do
    expect(rule.check(context_with(
      "use e.g. red. Then continue with etc. as needed"
    ))).to eq([])
  end

  it "passes for e.g. and i.e. without trailing commas" do
    expect(rule.check(context_with("e.g. red and i.e. blue"))).to eq([])
  end
end
