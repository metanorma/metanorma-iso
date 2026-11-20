# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FormulaTransformer do
  def formula_in(formula_xml)
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>ISO 1</docidentifier><language>en</language></bibdata>
        <sections><clause id="c1"><title>Scope</title>#{formula_xml}</clause></sections>
      </metanorma>
    XML
    context = Metanorma::Iso::Sts::Transformer::Context.new(source)
    model = described_class.new(context).transform(source.sections.first.formulas.first)
    Nokogiri::XML(model.to_xml).root
  end

  let(:mathml_ns) { "http://www.w3.org/1998/Math/MathML" }
  let(:stem) { %(<stem type="MathML"><math xmlns="#{mathml_ns}"><mi>x</mi><mo>=</mo><mn>2</mn></math></stem>) }

  it "emits <disp-formula> keeping the source id and the MathML" do
    el = formula_in(%(<formula id="eq1">#{stem}</formula>))

    expect(el.name).to eq("disp-formula")
    expect(el["id"]).to eq("eq1")
    math = el.at_xpath("./m:math", "m" => mathml_ns)
    expect(math).not_to be_nil
    expect(math.xpath("./m:mi | ./m:mo | ./m:mn", "m" => mathml_ns).map(&:text)).to eq(["x", "=", "2"])
  end

  it "emits the presentation formula name as <label>" do
    el = formula_in(%(<formula id="eq1"><fmt-name>(1)</fmt-name>#{stem}</formula>))

    expect(el.at_xpath("./label")&.text).to eq("(1)")
  end

  it "emits no label without a presentation name" do
    el = formula_in(%(<formula id="eq1">#{stem}</formula>))

    expect(el.at_xpath("./label")).to be_nil
  end

  it "emits no math for a formula without a stem" do
    el = formula_in(%(<formula id="eq1"/>))

    expect(el.name).to eq("disp-formula")
    expect(el.at_xpath("./m:math", "m" => mathml_ns)).to be_nil
  end
end
