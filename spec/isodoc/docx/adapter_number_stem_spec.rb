# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Adapter do
  # flatten_number_stems is private; exercised without building a document.
  let(:adapter) { described_class.allocate }
  let(:mathml) { "http://www.w3.org/1998/Math/MathML" }

  def flatten(xml)
    adapter.send(:flatten_number_stems, xml)
  end

  def doc(body)
    "<metanorma xmlns=\"http://riboseinc.com/isoxml\">#{body}</metanorma>"
  end

  def math(inner)
    "<math xmlns=\"#{mathml}\">#{inner}</math>"
  end

  it "flattens a lone number stem to text" do
    result = flatten(doc("<stem type=\"MathML\">#{math('<mn>12.5</mn>')}</stem>"))

    expect(result).to include('<stem type="MathML"><asciimath>12.5</asciimath></stem>')
  end

  it "flattens a lone number fmt-stem to text" do
    result = flatten(doc("<fmt-stem>#{math('<mstyle displaystyle="true"><mn>-5</mn></mstyle>')}</fmt-stem>"))

    expect(result).to include("<fmt-stem>-5</fmt-stem>")
  end

  it "leaves a formula stem alone" do
    xml = doc("<formula><stem type=\"MathML\">#{math('<mn>1</mn>')}</stem></formula>")

    expect(flatten(xml)).to include("<mn>1</mn>")
  end

  it "leaves a number with an operator alone" do
    xml = doc("<stem type=\"MathML\">#{math('<mn>1</mn><mo>+</mo><mn>2</mn>')}</stem>")

    expect(flatten(xml)).to include("<mo>+</mo>")
  end

  it "leaves a stem carrying asciimath next to the number alone" do
    xml = doc("<stem type=\"MathML\">#{math('<mn>1</mn>')}<asciimath>1</asciimath></stem>")

    expect(flatten(xml)).to include("<mn>1</mn>")
  end

  it "leaves a semx stem with mixed content alone" do
    xml = doc("<fmt-stem><semx source=\"x\">#{math('<mn>1</mn>')}<asciimath>1</asciimath></semx></fmt-stem>")

    expect(flatten(xml)).to include("<mn>1</mn>")
  end

  it "leaves an mstyle with color attributes alone" do
    xml = doc("<stem type=\"MathML\">#{math('<mstyle mathcolor="red" scriptlevel="1"><mn>-5</mn></mstyle>')}</stem>")

    expect(flatten(xml)).to include('mathcolor="red"')
  end

  it "returns malformed input unchanged" do
    ["<a><b></a>", "garbage"].each do |xml|
      expect(flatten(xml)).to eq(xml)
    end
  end
end
