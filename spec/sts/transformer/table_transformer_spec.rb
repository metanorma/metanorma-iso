# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::TableTransformer do
  include TransformerUnitSupport

  let(:sections) do
    <<~XML
      <clause id="c1"><title>Clause</title>
        <table id="t1" autonum="2"><name>Dimensions</name>
          <thead><tr><th id="h1">Item</th><th id="h2">Size</th></tr></thead>
          <tbody>
            <tr><td id="d1">Rod <strong>A</strong></td><td id="d2">5</td></tr>
            <tr><td id="d3"><em>Pipe</em> B</td><td id="d4"><p id="cp">para</p></td></tr>
          </tbody>
        </table>
        <table id="t2"><tbody><tr><td id="e1">only</td></tr></tbody></table>
      </clause>
    XML
  end
  let(:context) { context_for(source_xml(sections: sections)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def table(id, **opts)
    xml_of(transformer.transform(node_of(root, "TableBlock", id: id), **opts))
  end

  it "emits a table-wrap with id, label, caption and table" do
    result = transformer.transform(node_of(root, "TableBlock", id: "t1"))

    expect(result).to be_a(Sts::TbxIsoTml::TableWrap)
    doc = xml_of(result)
    expect(doc.at_xpath("/table-wrap/@id").value).to eq("t1")
    expect(doc.at_xpath("/table-wrap/label").text).to eq("Table 2")
    expect(doc.at_xpath("/table-wrap/caption/title").text).to eq("Dimensions")
  end

  it "maps head cells to th and body cells to td" do
    doc = table("t1")

    expect(doc.xpath("/table-wrap/table/thead/tr/th").map(&:text)).to eq(%w[Item Size])
    expect(doc.xpath("/table-wrap/table/tbody/tr").size).to eq(2)
    expect(doc.xpath("/table-wrap/table/tbody/tr[1]/td").map(&:text)).to eq(["Rod A", "5"])
  end

  it "keeps inline strong and em as bold and italic inside the cell" do
    doc = table("t1")

    expect(doc.at_xpath("//tbody/tr[1]/td[1]/bold").text).to eq("A")
    expect(doc.at_xpath("//tbody/tr[2]/td[1]/italic").text).to eq("Pipe")
  end

  it "carries block paragraphs inside a cell as p" do
    expect(table("t1").at_xpath("//tbody/tr[2]/td[2]/p").text).to eq("para")
  end

  it "emits no label and no caption for a bare table" do
    doc = table("t2")

    expect(doc.xpath("/table-wrap/label")).to be_empty
    expect(doc.xpath("/table-wrap/caption")).to be_empty
    expect(doc.at_xpath("//tbody/tr/td").text).to eq("only")
  end

  it "bolds header cell text when bold_header is set" do
    doc = table("t1", bold_header: true)

    expect(doc.xpath("//thead/tr/th/bold").map(&:text)).to eq(%w[Item Size])
  end

  it "does not bold header text by default" do
    expect(table("t1").xpath("//thead/tr/th/bold")).to be_empty
  end

  it "applies the id, content-type and specific-use overrides" do
    doc = table("t2", id: "rc-1", content_type: "modspec-class", specific_use: "modspec")

    expect(doc.at_xpath("/table-wrap/@id").value).to eq("rc-1")
    expect(doc.at_xpath("/table-wrap/@content-type").value).to eq("modspec-class")
    expect(doc.at_xpath("/table-wrap/@specific-use").value).to eq("modspec")
  end
end
