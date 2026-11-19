# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Adapter do # rubocop:disable RSpec/SpecFilePathFormat
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

  # The shape Asciidoctor emits for stem:[0].
  it "flattens a stem whose asciimath copy holds the same number" do
    xml = doc("<stem block=\"false\" type=\"MathML\">" \
              "#{math('<mstyle displaystyle="false"><mn>0</mn></mstyle>')}" \
              "<asciimath>0</asciimath></stem>")

    expect(flatten(xml))
      .to include('<stem block="false" type="MathML"><asciimath>0</asciimath></stem>')
  end

  it "flattens a stem whose asciimath and latexmath copies hold the same number" do
    xml = doc("<stem type=\"MathML\">#{math('<mn>42</mn>')}" \
              "<asciimath>42</asciimath><latexmath>42</latexmath></stem>")

    expect(flatten(xml)).to include('<stem type="MathML"><asciimath>42</asciimath></stem>')
  end

  it "leaves a stem whose asciimath differs from the number alone" do
    xml = doc("<stem type=\"MathML\">#{math('<mn>1</mn>')}<asciimath>1.0</asciimath></stem>")

    expect(flatten(xml)).to include("<mn>1</mn>")
  end

  it "flattens inside a fmt-stem semx and keeps the semx" do
    xml = doc("<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"x\">" \
              "#{math('<mstyle displaystyle="false"><mn>1</mn></mstyle>')}" \
              "<asciimath>1</asciimath></semx></fmt-stem>")

    expect(flatten(xml)).to include('<fmt-stem type="MathML"><semx element="stem" source="x">' \
                                    "<asciimath>1</asciimath></semx></fmt-stem>")
  end

  it "leaves a semx whose asciimath differs from the number alone" do
    xml = doc("<fmt-stem><semx source=\"x\">#{math('<mn>1</mn>')}<asciimath>x</asciimath></semx></fmt-stem>")

    expect(flatten(xml)).to include("<mn>1</mn>")
  end

  ["101 325", "101 325", "101 325", "-101 325", "−101 325"].each do |value|
    it "flattens the grouped number #{value.inspect}", :aggregate_failures do
      result = Nokogiri::XML(flatten(doc("<stem type=\"MathML\">#{math("<mn>#{value}</mn>")}</stem>")))
      stem = result.at("//*[local-name()='stem']")

      expect(stem.element_children.map(&:name)).to eq(["asciimath"])
      expect(stem.text).to eq(value)
    end
  end

  it "leaves badly grouped digits alone" do
    xml = doc("<stem type=\"MathML\">#{math('<mn>1 2</mn>')}</stem>")

    expect(flatten(xml)).to include("<mn>1 2</mn>")
  end

  describe "fmt-stem rendering" do
    let(:context) { IsoDoc::Iso::Docx::Context.new }
    let(:resolver) do
      IsoDoc::Iso::Docx::StyleResolver.new(IsoDoc::Iso::DocxStyleMapping.new, context)
    end
    let(:inline) do
      IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver,
                                            Uniword::Builder::DocumentBuilder.new)
    end

    def fmt_stem(inner)
      "<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"x\">#{inner}</semx></fmt-stem>"
    end

    # Whole runs, so text and run properties (the Stem style) both count.
    def runs(fmt_stem_xml)
      stem = parse_model_with_ordering(
        Metanorma::Document::Components::Inline::FmtStemElement, fmt_stem_xml
      )
      para = Uniword::Builder::ParagraphBuilder.new
      IsoDoc::Iso::Docx::InlineRenderers::StemRenderer.new(inline).render(stem, para)
      para.build.runs.map { |run| run.to_xml.gsub(/>\s+</, "><") }
    end

    [["<mn>101325</mn>", "<asciimath>101325</asciimath>"],
     ["<mstyle displaystyle=\"false\"><mn>-5</mn></mstyle>", ""]].each do |mn, copy|
      it "renders the same runs after flattening #{mn}", :aggregate_failures do
        before = fmt_stem("#{math(mn)}#{copy}")
        after = flatten(doc(before))[%r{<fmt-stem.*</fmt-stem>}m]

        expect(after).to match(/<semx[^>]*><asciimath>/)
        expect(runs(after)).not_to be_empty
        expect(runs(after)).to eq(runs(before))
      end
    end
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
