require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleBoxedValuesRule do
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

  it "flags a boxed percent value" do
    issues = rule.check(context_with("<p>the content is [13,0 %] by mass</p>"))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("boxed value")
    expect(issues.first.message).to include("plain value")
  end

  it "flags a boxed unit value" do
    issues = rule.check(context_with("<p>a depth of [10 mm] is assumed</p>"))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("[10 mm]")
  end

  it "does not flag digits-only citation callouts" do
    expect(rule.check(context_with("<p>see the references [1] and [2] for details</p>"))).to eq([])
  end

  it "does not flag a bare boxed integer" do
    expect(rule.check(context_with("<p>the value of [10] is documented elsewhere</p>"))).to eq([])
  end

  it "does not flag stem paragraphs" do
    issues = rule.check(context_with('<p type="stem">the value is [10 mm]</p>'))
    expect(issues).to eq([])
  end

  it "flags each boxed value separately" do
    issues = rule.check(context_with("<p>layers of [10 mm] and [13,0 %] are typical</p>"))
    expect(issues.size).to eq(2)
  end
end
