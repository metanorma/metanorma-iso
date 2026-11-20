# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# Three table shapes that used to lose content: a table nested in a cell, a
# footnote in the table name, and a dl with a footnote inside a cell.
RSpec.describe "table content gaps" do
  let(:adapter) { build_adapter }
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  def converted_document(table_xml)
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title>#{table_xml}</clause></sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      adapter.convert(xml, path)
      Nokogiri::XML(Zip::File.open(path) { |z| z.read("word/document.xml") })
    end
  end

  def val(node)
    node&.attribute_with_ns("val", ns["w"])&.value
  end

  context "with a table nested in a cell" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><thead><tr><th>A</th><th>B</th></tr></thead>
        <tbody><tr><td>outer</td><td>before
          <table id="t2"><tbody><tr><td>inner1</td><td>inner2</td></tr></tbody></table>
        </td></tr></tbody></table>
      XML
    end
    let(:outer) { doc.at_xpath("//w:body/w:tbl", ns) }
    let(:cell) { outer.xpath("w:tr", ns).last.xpath("w:tc", ns).last }

    it "keeps the inner table inside the cell" do
      expect(cell.xpath("w:tbl//w:tc", ns).map(&:text)).to eq(%w[inner1 inner2])
    end

    it "ends the cell with a paragraph, as Word requires" do
      expect(cell.element_children.last.name).to eq("p")
    end

    it "keeps the cell's own text" do
      expect(cell.xpath("w:p", ns).map(&:text).join).to include("before")
    end
  end

  context "with a footnote in the table name" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><fmt-name><semx element="title" source="_">Caption<fn reference="a"><p>Name note.</p></fn></semx></fmt-name>
        <thead><tr><th>A</th><th>B</th></tr></thead>
        <tbody><tr><td>x</td><td>y</td></tr></tbody></table>
      XML
    end
    let(:tbl) { doc.at_xpath("//w:body/w:tbl", ns) }

    it "puts the label in the caption and no Word footnote anywhere" do
      caption = tbl.xpath("preceding-sibling::w:p", ns).last
      expect(caption.text).to include("Caption")
      expect(caption.xpath(".//w:r[w:rPr/w:vertAlign]", ns).map(&:text)).to eq(["a"])
      expect(doc.xpath("//w:footnoteReference", ns)).to be_empty
    end

    it "puts the body in the last table row" do
      last = tbl.xpath("w:tr", ns).last
      expect(last.xpath("w:tc", ns).size).to eq(1)
      expect(last.text).to eq("a Name note.")
    end
  end

  context "with a dl holding a footnote inside a cell" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><thead><tr><th>A</th><th>B</th></tr></thead>
        <tbody><tr><td>x</td><td><dl><dt>term</dt><dd><p>def<fn reference="a"><p>Dl note.</p></fn></p></dd></dl></td></tr></tbody></table>
      XML
    end
    let(:tbl) { doc.at_xpath("//w:body/w:tbl", ns) }

    it "keeps the dl text and its label in the cell" do
      cell = tbl.xpath("w:tr", ns)[1].xpath("w:tc", ns).last
      expect(cell.text).to include("term").and include("def")
      expect(cell.xpath(".//w:r[w:rPr/w:vertAlign]", ns).map(&:text)).to eq(["a"])
    end

    it "collects the body in the last table row" do
      last = tbl.xpath("w:tr", ns).last
      expect(last.xpath("w:tc", ns).size).to eq(1)
      expect(last.text).to eq("a Dl note.")
      expect(doc.xpath("//w:footnoteReference", ns)).to be_empty
    end
  end

  context "with two tables side by side in one cell" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><tbody><tr><td><table id="t2"><tbody><tr><td>one</td></tr></tbody></table><table id="t3"><tbody><tr><td>two</td></tr></tbody></table></td></tr></tbody></table>
      XML
    end

    it "separates them with a paragraph so Word does not fuse them" do
      cell = doc.at_xpath("//w:body/w:tbl/w:tr/w:tc", ns)
      expect(cell.element_children.map(&:name).reject { |n| n == "tcPr" }).to eq(%w[tbl p tbl p])
    end
  end

  context "with a dl of several paragraphs per dd, and an empty dl, in cells" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><tbody><tr><td><dl><dt>term</dt><dd><p>first</p><p>second</p></dd></dl></td><td><dl></dl></td></tr></tbody></table>
      XML
    end
    let(:cells) { doc.at_xpath("//w:body/w:tbl/w:tr", ns).xpath("w:tc", ns) }

    it "gives each dd paragraph its own paragraph" do
      expect(cells.first.xpath("w:p", ns).map(&:text)).to eq(%w[term first second])
    end

    it "keeps a paragraph in the cell of an empty dl" do
      expect(cells.last.xpath("w:p", ns).size).to eq(1)
    end
  end

  context "with block content inside a dd in a cell" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><tbody><tr><td><dl>
        <dt>a</dt><dd><p>intro</p><ul><li><p>bullet</p></li></ul></dd>
        <dt>b</dt><dd><ol><li><p>first</p></li></ol></dd>
        <dt>c</dt><dd><dl><dt>nt</dt><dd><p>nd</p></dd></dl></dd>
        </dl></td></tr></tbody></table>
      XML
    end
    let(:cell) { doc.at_xpath("//w:body/w:tbl/w:tr/w:tc", ns) }

    it "keeps the paragraph, list items and nested dl of each dd" do
      expect(cell.xpath("w:p", ns).map(&:text)).to eq(%w[a intro bullet b first c nt nd])
    end

    it "numbers the list items" do
      expect(cell.xpath("w:p[w:pPr/w:numPr]", ns).map(&:text)).to eq(%w[bullet first])
    end
  end

  context "with two different footnotes sharing a reference and no target" do
    let(:doc) do
      converted_document(<<~XML)
        <table id="t1"><tbody><tr><td>x<fn reference="a"><p>First body.</p></fn></td><td>y<fn reference="a"><p>Second body.</p></fn></td></tr></tbody></table>
      XML
    end

    it "keeps both bodies in the table foot" do
      rows = doc.at_xpath("//w:body/w:tbl", ns).xpath("w:tr", ns)
      expect(rows.last.text).to include("First body.").and include("Second body.")
    end
  end

  context "with a table, loose text or a lone dd in a dl inside a cell" do
    def cell_of(cell_xml)
      converted_document(%(<table id="t1"><tbody><tr><td>#{cell_xml}</td></tr></tbody></table>))
        .at_xpath("//w:body/w:tbl/w:tr/w:tc", ns)
    end

    it "ends a cell with a paragraph when its last dd ends in a table" do
      cell = cell_of(<<~XML)
        <dl><dt>a</dt><dd><table id="t2"><tbody><tr><td>inner</td></tr></tbody></table></dd></dl>
      XML
      expect(cell.xpath("w:tbl//w:tc", ns).map(&:text)).to eq(["inner"])
      expect(cell.element_children.last.name).to eq("p")
    end

    it "keeps text that sits beside a list in a dd" do
      cell = cell_of("<dl><dt>a</dt><dd>LOOSE<ul><li><p>b</p></li></ul></dd></dl>")
      expect(cell.xpath("w:p", ns).map(&:text)).to eq(%w[a LOOSE b])
    end

    it "keeps a dd that has no dt" do
      cell = cell_of("<dl><dd><p>orphan</p></dd></dl>")
      expect(cell.xpath("w:p", ns).map(&:text)).to eq(%w[orphan])
    end
  end
end
