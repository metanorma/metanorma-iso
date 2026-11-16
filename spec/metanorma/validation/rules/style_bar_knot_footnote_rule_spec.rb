require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleBarKnotFootnoteRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(body_xml)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            #{body_xml}
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags a formula using bar without the mandated footnote" do
    issues = rule.check(context_with(
      '<p>pressure <stem type="AsciiMath"><asciimath>p = 5 bar</asciimath></stem></p>'
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_72")
    expect(issues.first.message).to include("bar")
  end

  it "flags a formula using kn without the mandated footnote" do
    issues = rule.check(context_with(
      '<p>speed <stem type="AsciiMath"><asciimath>v = 20 kn</asciimath></stem></p>'
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("1,852")
  end

  it "does not flag bar when the footnote is present" do
    expect(rule.check(context_with(
      '<p>pressure <fn id="fn1"><p>1 bar = 0,1 MPa.</p></fn>' \
      '<stem type="AsciiMath"><asciimath>p = 5 bar</asciimath></stem></p>'
    ))).to eq([])
  end

  it "does not flag kn when the footnote is present" do
    expect(rule.check(context_with(
      '<p>speed <fn id="fn2"><p>1 kn = 1,852 km/h.</p></fn>' \
      '<stem type="AsciiMath"><asciimath>v = 20 kn</asciimath></stem></p>'
    ))).to eq([])
  end

  it "does not flag the LaTeX overline accent \\bar" do
    expect(rule.check(context_with(
      '<p>height <stem type="Latex"><latexmath>\bar{x}</latexmath></stem></p>'
    ))).to eq([])
  end

  it "does not flag formulae without bar or kn" do
    expect(rule.check(context_with(
      '<p>voltage <stem type="AsciiMath"><asciimath>U = 5 V</asciimath></stem></p>'
    ))).to eq([])
  end
end
