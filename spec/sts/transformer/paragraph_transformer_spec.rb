# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::ParagraphTransformer do
  include TransformerUnitSupport

  let(:sections) do
    <<~XML
      <clause id="c1"><title>Clause</title>
        <p id="plain">Just text</p>
        <p id="fmt">A <em>it</em> B <strong>bd</strong> C <tt>code</tt></p>
        <p id="scripts">H<sub>2</sub>O and x<sup>2</sup> and y<sub>ab</sub></p>
        <p id="refs">See <xref target="c1"/> and <link target="http://example.org/x">the site</link> or <link target="mailto:a@b.org">mail</link></p>
        <p id="nested"><strong>bold <em>and italic</em></strong></p>
      </clause>
    XML
  end
  let(:context) { context_for(source_xml(sections: sections)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def para(id)
    xml_of(transformer.transform(node_of(root, "ParagraphBlock", id: id)))
  end

  it "emits a p carrying the source id and text" do
    result = transformer.transform(node_of(root, "ParagraphBlock", id: "plain"))

    expect(result).to be_a(Sts::NisoSts::Paragraph)
    doc = xml_of(result)
    expect(doc.at_xpath("/p/@id").value).to eq("plain")
    expect(doc.at_xpath("/p").text).to eq("Just text")
  end

  it "maps em, strong and tt to italic, bold and monospace" do
    doc = para("fmt")

    expect(doc.at_xpath("/p/italic").text).to eq("it")
    expect(doc.at_xpath("/p/bold").text).to eq("bd")
    expect(doc.at_xpath("/p/monospace").text).to eq("code")
    expect(doc.at_xpath("/p").text).to eq("A it B bd C code")
  end

  it "keeps the text of sub and sup" do
    doc = para("scripts")

    expect(doc.xpath("/p/sub").map(&:text)).to eq(%w[2 ab])
    expect(doc.xpath("/p/sup").map(&:text)).to eq(["2"])
    expect(doc.at_xpath("/p").text).to eq("H2O and x2 and yab")
  end

  it "maps xref to an STS xref with rid and ref-type" do
    xref = para("refs").at_xpath("/p/xref")

    expect(xref["rid"]).to eq("c1")
    expect(xref["ref-type"]).to eq("sec")
  end

  it "maps link to ext-link with xlink:href and strips mailto: from the visible text" do
    links = para("refs").xpath("/p/ext-link")

    expect(links.map { |l| l["href"] }).to eq(["http://example.org/x", "mailto:a@b.org"])
    expect(links.map(&:text)).to eq(["the site", "a@b.org"])
    expect(links.map { |l| l["ext-link-type"] }.uniq).to eq(["uri"])
  end

  it "nests italic inside bold" do
    doc = para("nested")

    expect(doc.at_xpath("/p/bold/italic").text).to eq("and italic")
    expect(doc.at_xpath("/p/bold").text).to eq("bold and italic")
  end
end
