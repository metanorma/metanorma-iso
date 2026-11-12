require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleChemPrefixRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }
  let(:mml_ns) { "http://www.w3.org/1998/Math/MathML" }

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

  def asciimath_stem(source)
    %Q(<p>given <stem type="AsciiMath"><asciimath>#{source}</asciimath></stem></p>)
  end

  def mathml_stem(markup)
    <<~XML.gsub("\n", "")
      <p>given <stem type="MathML"><math xmlns="#{mml_ns}">#{markup}</math></stem></p>
    XML
  end

  it "flags a quoted upright prefix in an AsciiMath stem" do
    issues = rule.check(context_with(asciimath_stem(%q("n"-butane))))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_145")
    expect(issues.first.message).to include("'n'")
    expect(issues.first.message).to include("italic")
  end

  it "flags a quoted cis prefix with a digit locant" do
    issues = rule.check(context_with(asciimath_stem(%q("cis"-2-butene))))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'cis'")
  end

  it "flags the N,N prefix" do
    issues = rule.check(context_with(asciimath_stem(%q("N","N"-dimethyl))))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'N,N'")
  end

  it "flags an upright prefix in MathML (mathvariant=normal)" do
    issues = rule.check(context_with(mathml_stem(
      '<mi mathvariant="normal">n</mi><mo>-</mo><mi>butane</mi>'
    )))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'n'")
  end

  it "flags an upright prefix in an mtext run" do
    issues = rule.check(context_with(mathml_stem(
      "<mtext>cis-</mtext><mn>2</mn><mi>butene</mi>"
    )))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'cis'")
  end

  it "does not flag an unquoted (italic) prefix" do
    expect(rule.check(context_with(
      asciimath_stem("n-butane")
    ))).to eq([])
  end

  it "does not flag an italic mathvariant prefix" do
    expect(rule.check(context_with(mathml_stem(
      '<mi mathvariant="italic">n</mi><mo>-</mo><mi>butane</mi>'
    )))).to eq([])
  end

  it "does not match a prefix inside a word" do
    expect(rule.check(context_with(
      asciimath_stem(%q("decision"-1))
    ))).to eq([])
  end

  it "does not flag an operator hyphen without a chemical token" do
    expect(rule.check(context_with(
      asciimath_stem("m - 3 = 0")
    ))).to eq([])
  end

  it "does not scan prose" do
    expect(rule.check(context_with(
      "<p>The cis isomer of butane is separated by distillation.</p>"
    ))).to eq([])
  end
end
