# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::TableRenderer do
  let(:adapter) { build_adapter }

  def table_paragraphs(pkg)
    tables = pkg.document.body.tables
    return [] if tables.empty?

    tables.flat_map do |tbl|
      tbl.rows.flat_map do |row|
        row.cells.flat_map { |cell| Array(cell.paragraphs) }
      end
    end
  end

  it "renders a table with header and body rows" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <fmt-name>Table 1 — Sample</fmt-name>
            <thead>
              <tr><th>H1</th><th>H2</th></tr>
            </thead>
            <tbody>
              <tr><td>C1</td><td>C2</td></tr>
            </tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      tables = pkg.document.body.tables
      expect(tables.length).to eq(1)
      expect(tables.first.rows.length).to eq(2),
        "expected 2 rows (1 header + 1 body), got #{tables.first.rows.length}"
      expect(tables.first.rows.first.cells.length).to eq(2),
        "expected 2 cells per row, got #{tables.first.rows.first.cells.length}"
    end
  end

  it "renders the table name with Tabletitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <fmt-name>Table 1 — Sample</fmt-name>
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>C1</td></tr></tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      title_paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p) == "Tabletitle"
      end

      expect(title_paras.length).to be >= 1,
        "table title should use Tabletitle style"
      title_text = title_paras.first.runs.map { |r| r.text || "" }.join
      expect(title_text).to include("Table 1")
    end
  end

  it "applies Tableheader style to header cell paragraphs" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>Header A</th></tr></thead>
            <tbody><tr><td>Body 1</td></tr></tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = table_paragraphs(pkg).map { |p| para_style_value(p) }
      expect(styles).to include("Tableheader"),
        "header cell paragraph should use Tableheader, got: #{styles.inspect}"
    end
  end

  it "applies Tablebody style to body cell paragraphs" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>Body cell</td></tr></tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = table_paragraphs(pkg).map { |p| para_style_value(p) }
      expect(styles).to include("Tablebody"),
        "body cell paragraph should use Tablebody, got: #{styles.inspect}"
    end
  end

  it "applies Tablefooter style to footer cell paragraphs" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>Body cell</td></tr></tbody>
            <tfoot><tr><td>Footer cell</td></tr></tfoot>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = table_paragraphs(pkg).map { |p| para_style_value(p) }
      expect(styles).to include("Tablefooter"),
        "footer cell paragraph should use Tablefooter, got: #{styles.inspect}"
    end
  end

  it "renders notes inside table cells with Note style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th></tr></thead>
            <tbody>
              <tr>
                <td>
                  <note id="n1"><p>Cell note text.</p></note>
                </td>
              </tr>
            </tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = table_paragraphs(pkg).map { |p| para_style_value(p) }
      expect(styles).to include("Note"),
        "note inside cell should use Note, got: #{styles.inspect}"
    end
  end

  it "renders table-level <note> siblings after the table body" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>Cell text.</td></tr></tbody>
            <note id="n1" autonum="1">
              <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">NOTE</span> 1</span><span class="fmt-label-delim"><tab/></span></fmt-name>
              <p>This table is based on ISO 7301.</p>
            </note>
            <note id="n2" autonum="2">
              <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">NOTE</span> 2</span><span class="fmt-label-delim"><tab/></span></fmt-name>
              <p>Some commercial contracts require more detail.</p>
            </note>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      # Era C wraps the table and its note attachments in an outer table,
      # so the notes live in the wrapper's second-row cell, not in
      # body-level paragraphs.
      cell_texts = table_paragraphs(pkg).map do |p|
        p.runs.map(&:text).join
      end
      joined = cell_texts.join

      expect(joined).to include("This table is based on ISO 7301."),
        "first table note body should be rendered after the table"
      expect(joined).to include("Some commercial contracts require more detail."),
        "second table note body should be rendered after the table"

      styles = table_paragraphs(pkg).map { |p| para_style_value(p).to_s }
      noteindent_count = styles.count("Noteindent")
      expect(noteindent_count).to eq(2),
        "expected 2 Noteindent paragraphs (one per table note), got #{noteindent_count}"
    end
  end

  it "renders lists inside table cells with numbering" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th></tr></thead>
            <tbody>
              <tr>
                <td>
                  <ul>
                    <li><p>Item one.</p></li>
                    <li><p>Item two.</p></li>
                  </ul>
                </td>
              </tr>
            </tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      dash_id = adapter.resolver.numbering_id(:dash_list)
      cell_list_paras = table_paragraphs(pkg).select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == dash_id
      end

      expect(cell_list_paras.length).to eq(2),
        "expected 2 dash_list paragraphs inside cell, got #{cell_list_paras.length}"
    end
  end

  it "dispatches TableBlock via exact-class lookup" do
    registry = IsoDoc::Iso::Docx::Renderers::Registry.new do |r|
      r.register(
        Metanorma::Document::Components::Tables::TableBlock,
        :table_renderer,
      )
    end

    expect(registry.lookup(Metanorma::Document::Components::Tables::TableBlock))
      .to eq(:table_renderer)
    expect(registry.registered?(Metanorma::Document::Components::Tables::TableBlock))
      .to be(true)
  end

  # Presentation XML keeps the semantic <stem> and adds an <fmt-stem> twin
  # inside the caption's <semx>; the caption must show the stem once, as an
  # inline OMML equation (Word supports OMML in captions).
  def caption_stem_xml
    '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mn>80</mn><mo rspace="thickmathspace">&#x2062;</mo><mrow xref="U_km"><mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow></mrow></math><asciimath>80 "unitsml(km)"</asciimath></stem>' \
      '<fmt-stem type="MathML"><semx element="stem" source="s1"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>80</mn></math><asciimath>80 "unitsml(km)"</asciimath></semx></fmt-stem>'
  end

  it "keeps a stem inside the table caption, once, as OMML" do
    name = "<fmt-name><semx element=\"name\">Tab #{caption_stem_xml}</semx></fmt-name>"
    xml = minimal_iso_xml("<sections><clause id=\"c1\"><title>Scope</title><table id=\"t1\">%s<tbody><tr><td>x</td></tr></tbody></table></clause></sections>" % name)
    convert_and_extract(adapter, xml) do |pkg|
      para = pkg.document.body.paragraphs.find { |x| para_style_value(x) == "Tabletitle" }
      omaths = Nokogiri::XML(para.to_xml).xpath("//m:oMath", "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math")
      text = para.runs.map { |r| run_text(r) }.join
      expect([text, omaths.map { |m| m.xpath(".//m:t", "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math").map(&:text) }])
        .to eq(["Tab ", [%w[80 km]]])
    end
  end
end
