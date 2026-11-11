require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleWikipediaRule do
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

  it "flags a wikipedia.org URL in text" do
    issues = rule.check(context_with(
      "<p>see en.wikipedia.org/wiki/ISO for details</p>"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("stable source")
  end

  it "flags a wikipedia.org link target" do
    issues = rule.check(context_with(
      "<p>see <link target='https://en.wikipedia.org/wiki/ISO'>ISO</link>" \
      "</p>"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("stable source")
  end

  it "passes for stable sources" do
    expect(rule.check(context_with(
      "<p>see <link target='https://www.iso.org/standard/1234.html'>" \
      "ISO</link></p>"
    ))).to eq([])
  end
end
