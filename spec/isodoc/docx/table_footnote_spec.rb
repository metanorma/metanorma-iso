# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# ISO table footnotes (<fn reference="a"> in a cell) stay inside the table:
# a superscript letter in the cell, and one full-width Tablefootnote row at the foot
# of the table holding each body once. They are not Word page footnotes.
RSpec.describe "table footnote rendering" do
  let(:adapter) { build_adapter }
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:body) do
    "<tr><td>x<fn reference=\"a\"><p>Body A.</p></fn></td><td>y</td><td>z</td></tr>" \
      "<tr><td>p<fn reference=\"a\"><p>Body A.</p></fn></td><td>q</td>" \
      "<td>r<fn reference=\"b\"><p>Body B.</p></fn></td></tr>"
  end

  def converted_table(tbody)
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1"><title>Scope</title>
          <table id="t1"><thead><tr><th>A</th><th>B</th><th>C</th></tr></thead>
          <tbody>#{tbody}</tbody></table>
        </clause>
      </sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      adapter.convert(xml, path)
      doc = Zip::File.open(path) { |z| z.read("word/document.xml") }
      Nokogiri::XML(doc).at_xpath("//w:tbl", ns)
    end
  end

  def val(node)
    node&.attribute_with_ns("val", ns["w"])&.value
  end

  it "uses no Word footnote references inside the table" do
    tbl = converted_table(body)
    expect(tbl.xpath(".//w:footnoteReference", ns)).to be_empty
  end

  it "marks each cell with a superscript reference letter" do
    tbl = converted_table(body)
    marks = tbl.xpath("w:tr[position() < last()]//w:r[w:rPr/w:vertAlign]", ns)
    expect(marks.map(&:text)).to eq(%w[a a b])
    expect(marks.map { |r| val(r.at_xpath("w:rPr/w:vertAlign", ns)) }.uniq).to eq(["superscript"])
  end

  it "adds one full-width Tablefootnote row with each body once" do
    tbl = converted_table(body)
    last = tbl.xpath("w:tr", ns).last
    cells = last.xpath("w:tc", ns)
    expect(cells.size).to eq(1)
    expect(val(cells.first.at_xpath("w:tcPr/w:gridSpan", ns))).to eq("3")
    paras = cells.first.xpath("w:p", ns)
    expect(paras.map { |p| val(p.at_xpath("w:pPr/w:pStyle", ns)) }.uniq).to eq(["Tablefootnote"])
    expect(paras.map(&:text)).to eq(["a Body A.", "b Body B."])
    expect(tbl.xpath("w:tblGrid/w:gridCol", ns).size).to eq(3)
  end

  it "adds no footnote row to a table without footnotes" do
    tbl = converted_table("<tr><td>x</td><td>y</td><td>z</td></tr>")
    expect(tbl.xpath("w:tr", ns).size).to eq(2)
  end
end
