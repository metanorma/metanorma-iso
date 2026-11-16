require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleStemSymbolRule do
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

  def stem(asciimath)
    %Q(<p>given <stem type="AsciiMath"><asciimath>#{asciimath}</asciimath></stem></p>)
  end

  it "flags a multi-letter quantity symbol" do
    issues = rule.check(context_with(stem("vol = 3 m^3")))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_144")
    expect(issues.first.message).to include("'vol'")
    expect(issues.first.message).to include("single letter with subscripts")
  end

  it "flags a multi-letter symbol in a MathML stem" do
    issues = rule.check(context_with(
      "<p>given <stem type=\"MathML\">" \
      '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
      "<mi>vol</mi><mo>=</mo><mn>3</mn></math></stem></p>"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("'vol'")
  end

  it "flags each distinct multi-letter symbol separately" do
    issues = rule.check(context_with(stem("ab + vol = 5")))
    expect(issues.map { |i| i.message }).to include(
      /'ab'/, /'vol'/
    )
  end

  it "does not flag a single letter with subscripts" do
    expect(rule.check(context_with(
      stem(%q(v_(max) = c_0 sqrt(E/rho)))
    ))).to eq([])
  end

  it "does not flag descriptive subscripts and quoted text" do
    expect(rule.check(context_with(
      stem(%q(E_"tot" = m c^2))
    ))).to eq([])
  end

  it "does not flag ISO 80000-11 characteristic numbers" do
    expect(rule.check(context_with(
      stem("Re = rho v L//mu")
    ))).to eq([])
  end

  it "does not flag spaced products of quantity symbols" do
    expect(rule.check(context_with(
      stem("A = v L t")
    ))).to eq([])
  end

  it "does not flag the function-application shape" do
    expect(rule.check(context_with(
      stem("Q = unit(m^3//s) cdot v")
    ))).to eq([])
  end

  it "does not flag differential notation" do
    expect(rule.check(context_with(
      stem("dQ//dt = alpha A")
    ))).to eq([])
  end

  it "does not flag an italic chemical prefix name" do
    expect(rule.check(context_with(
      stem("n-butane")
    ))).to eq([])
  end

  it "does not flag prose that merely mentions symbols" do
    expect(rule.check(context_with(
      "<p>The volume vol is measured in cubic metres.</p>"
    ))).to eq([])
  end
end
