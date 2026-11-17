# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# A NOTE following a table in the source is a table-level annotation: the
# presentation XML makes it a direct child of <table>, a sibling of
# <thead>/<tbody>/<tfoot>. TableRenderer wraps such a table and its
# attachments in an outer 2-row table — the annotated table itself lives in
# the wrapper's first-row cell, the attachments in the second. The MHTML
# writer used to render only a cell's paragraphs, so the nested table — and
# with it every row of the annotated table — vanished from .doc output
# while .docx kept it (isodoc#898).
RSpec.describe "table-attached note rendering" do
  let(:adapter) { build_adapter }

  let(:table_note_xml) do
    minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <fmt-name>Table 1 — Profile</fmt-name>
            <thead><tr><th>Profile</th><th>NDI</th></tr></thead>
            <tbody>
              <tr><td>Core</td><td>0 or 1</td></tr>
              <tr><td>Constrained</td><td>0 or 1</td></tr>
            </tbody>
            <note id="n1" autonum="1">
              <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">NOTE</span> 1</span><span class="fmt-label-delim"><tab/></span></fmt-name>
              <p>This note follows the table.</p>
            </note>
          </table>
        </clause>
      </sections>
    INNER
  end

  # Flat text of every run in a table's rows, in document order.
  def table_cell_texts(table)
    table.rows.flat_map do |row|
      row.cells.flat_map do |cell|
        cell.paragraphs.flat_map do |para|
          para.runs.map { |run| Array(run.text).join }
        end
      end
    end
  end

  it "keeps the annotated table's rows in the wrapper's first row" do
    convert_and_extract(adapter, table_note_xml) do |pkg|
      tables = pkg.document.body.tables
      expect(tables.length).to eq(1), "expected one (wrapper) table"

      wrapper = tables.first
      expect(wrapper.rows.length).to eq(2),
                                     "the wrapper carries the table and its attachments in two rows"

      inner_tables = wrapper.rows.first.cells.flat_map(&:tables)
      expect(inner_tables.length).to eq(1),
                                     "the wrapper's first-row cell must nest the annotated table"

      texts = table_cell_texts(inner_tables.first)
      expect(texts).to include("Profile", "NDI", "Core", "0 or 1", "Constrained"),
                       "every row of the annotated table must survive the wrapper"
    end
  end

  it "renders the attached note after the table region" do
    convert_and_extract(adapter, table_note_xml) do |pkg|
      wrapper = pkg.document.body.tables.first

      note_paras = wrapper.rows[1].cells.flat_map(&:paragraphs)
      note_text = note_paras.flat_map do |para|
        para.runs.map { |run| Array(run.text).join }
      end.join
      expect(note_text).to include("This note follows the table."),
                           "the table-attached note must render after the table"

      expect(note_paras.map { |p| para_style_value(p) }).to all(eq("Noteindent")),
                                                            "the note body paragraphs use the Noteindent style"
    end
  end

  it "renders an attached example after the table region too" do
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
            <tbody><tr><td>Body cell.</td></tr></tbody>
            <example id="e1">
              <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">EXAMPLE</span></span><span class="fmt-label-delim"><tab/></span></fmt-name>
              <p>This example follows the table.</p>
            </example>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      wrapper = pkg.document.body.tables.first
      expect(wrapper.rows.length).to eq(2)

      attachment_text = wrapper.rows[1].cells.flat_map do |cell|
        cell.paragraphs.flat_map do |para|
          para.runs.map { |run| Array(run.text).join }
        end
      end.join
      expect(attachment_text).to include("This example follows the table."),
                                 "the table-attached example must render after the table"

      styles = wrapper.rows[1].cells.flat_map(&:paragraphs)
        .map { |p| para_style_value(p) }
      expect(styles).to include("Example"),
                        "the example body uses the Example style, got: #{styles.inspect}"
    end
  end

  it "renders a table without attachments unwrapped" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <table id="t1">
            <thead><tr><th>H1</th><th>H2</th></tr></thead>
            <tbody><tr><td>C1</td><td>C2</td></tr></tbody>
          </table>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      tables = pkg.document.body.tables
      expect(tables.length).to eq(1), "a plain table needs no wrapper"

      table = tables.first
      expect(table.rows.length).to eq(2)
      expect(table_cell_texts(table)).to include("H1", "H2", "C1", "C2")

      nested = table.rows.flat_map(&:cells).flat_map(&:tables)
      expect(nested).to be_empty, "a plain table must not be nested in a wrapper"
    end
  end

  # The reporter-facing surface: the .doc (MHTML) writer must render the
  # nested table inside its cell, so the rows appear before the note.
  it "keeps the rows ahead of the note in the .doc (MHTML) output" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.doc")
      adapter.convert(table_note_xml, path)

      package = Uniword::Mhtml::MhtmlPackage.from_file(path)
      html = package.html_part.decoded_content
      doc = Nokogiri::HTML(html)

      core_cell = doc.at_xpath("//td[.='Core']")
      expect(core_cell).not_to be_nil,
                               "the annotated table's rows must survive in the MHTML output"
      expect(doc.at_xpath("//td[.='NDI']")).not_to be_nil
      expect(doc.at_xpath("//td[.='Constrained']")).not_to be_nil

      note_cell = doc.at_xpath("//td[contains(., 'This note follows the table.')]")
      expect(note_cell).not_to be_nil,
                               "the table-attached note must survive in the MHTML output"

      # The note belongs to the annotated table's wrapper and sits in a
      # row after the row holding the table itself. The ancestor axis is
      # nearest-first, so the nearest table containing both cells is the
      # wrapper around the annotated table and its note.
      wrapper = (core_cell.xpath("ancestor::table") &
                 note_cell.xpath("ancestor::table")).first
      expect(wrapper).not_to be_nil,
                             "the note must render inside the annotated table's wrapper"

      rows = wrapper.xpath("./tr")
      core_row = rows.find { |r| r.at_xpath(".//td[.='Core']") }
      note_row = rows.find { |r| r.at_xpath(".//td[contains(., 'This note follows the table.')]") }
      expect(rows.index(core_row)).to be < rows.index(note_row),
                                      "the note must come after the table rows, not replace them"
    end
  end
end
