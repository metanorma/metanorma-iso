# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# <td rowspan="n"> must become OOXML vertical merges: w:vMerge w:val="restart"
# on the spanning cell and an empty w:tc with a bare w:vMerge (same
# gridSpan) in every covered row, at the covered grid position.
RSpec.describe "table rowspan rendering" do
  let(:adapter) { build_adapter }
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  def table_xml(thead, tbody)
    minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1"><title>Scope</title>
          <table id="t1"><thead>#{thead}</thead><tbody>#{tbody}</tbody></table>
        </clause>
      </sections>
    INNER
  end

  # Serialised rows of the first w:tbl as arrays of
  # { text:, merge: nil|"restart"|:continue, span: Integer }.
  def rows_of(xml)
    out = nil
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      adapter.convert(xml, path)
      doc = Zip::File.open(path) { |z| z.read("word/document.xml") }
      tbl = Nokogiri::XML(doc).at_xpath("//w:tbl", ns)
      out = tbl.xpath("w:tr", ns).map do |tr|
        tr.xpath("w:tc", ns).map do |tc|
          vm = tc.at_xpath("w:tcPr/w:vMerge", ns)
          merge = vm && (vm["w:val"] || vm.attribute_with_ns("val", ns["w"])&.value || :continue)
          gs = tc.at_xpath("w:tcPr/w:gridSpan", ns)
          { text: tc.text, merge: merge,
            span: gs ? gs.attribute_with_ns("val", ns["w"]).value.to_i : 1 }
        end
      end
      @grid = tbl.xpath("w:tblGrid/w:gridCol", ns).size
    end
    out
  end

  it "restarts on the spanning cell and continues at the same column" do
    rows = rows_of(table_xml(
                     "<tr><th>A</th><th>B</th><th>C</th></tr>",
                     "<tr><td>x</td><td rowspan=\"2\">tall</td><td>z</td></tr>" \
                     "<tr><td>p</td><td>r</td></tr>",
                   ))
    expect(rows[1].map { |c| c[:merge] }).to eq([nil, "restart", nil])
    expect(rows[2].map { |c| c[:merge] }).to eq([nil, :continue, nil])
    expect(rows[2].map { |c| c[:text] }).to eq(["p", "", "r"])
    expect(rows[2].size).to eq(rows[1].size)
  end

  it "keeps gridSpan on a rowspan+colspan cell and its continuation" do
    rows = rows_of(table_xml(
                     "<tr><th>A</th><th>B</th><th>C</th></tr>",
                     "<tr><td rowspan=\"2\" colspan=\"2\">big</td><td>z</td></tr>" \
                     "<tr><td>r</td></tr>",
                   ))
    expect(rows[1].first).to include(merge: "restart", span: 2)
    expect(rows[2].first).to include(merge: :continue, span: 2, text: "")
    expect(rows[2].size).to eq(2)
    expect(@grid).to eq(3)
  end

  it "ends a covered row with its continuation and spans 3 rows" do
    rows = rows_of(table_xml(
                     "<tr><th>A</th><th>B</th></tr>",
                     "<tr><td>x</td><td rowspan=\"3\">tall</td></tr>" \
                     "<tr><td>y</td></tr><tr><td>w</td></tr>",
                   ))
    expect(rows[1].map { |c| c[:merge] }).to eq([nil, "restart"])
    expect(rows[2].map { |c| c[:merge] }).to eq([nil, :continue])
    expect(rows[3].map { |c| c[:merge] }).to eq([nil, :continue])
  end

  it "places a header-row spanning cell's continuation first in the next row" do
    rows = rows_of(table_xml(
                     "<tr><th rowspan=\"2\">H</th><th>B</th></tr><tr><th>C</th></tr>",
                     "<tr><td>1</td><td>2</td></tr>",
                   ))
    expect(rows[0].map { |c| c[:merge] }).to eq(["restart", nil])
    expect(rows[1].map { |c| c[:merge] }).to eq([:continue, nil])
    expect(rows[2].map { |c| c[:merge] }).to eq([nil, nil])
  end
end
