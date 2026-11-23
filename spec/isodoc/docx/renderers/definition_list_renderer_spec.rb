# frozen_string_literal: true

require_relative "../spec_helper"
require "cgi"

RSpec.describe IsoDoc::Iso::Docx::Renderers::DefinitionListRenderer do
  let(:adapter) { build_adapter }

  # Concatenated text of every cell of a Uniword table.
  def cell_text(table)
    table.rows.flat_map do |row|
      row.cells.flat_map do |cell|
        cell.paragraphs.flat_map { |p| p.runs.map { |r| run_text(r) } }
      end
    end.join
  end

  describe "formula key tables" do
    def formula_key_xml
      minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><mo>=</mo><mi>y</mi></math></stem>
              <key class="formula_dl">
                <dl>
                  <dt>X</dt>
                  <dd><p>The X coordinate<fn reference="a" target="fn-a"/></p></dd>
                  <dt>Y</dt>
                  <dd><p>The Y coordinate<fn reference="a" target="fn-a"/></p></dd>
                </dl>
              </key>
              <fmt-footnote-container>
                <fmt-fn-body id="fn-a" reference="a">
                  <semx element="fn"><p>Measured from the origin.</p></semx>
                </fmt-fn-body>
              </fmt-footnote-container>
            </formula>
          </clause>
        </sections>
      INNER
    end

    def formula_key_properties(doc, namespaces)
      table = doc.at_xpath("//w:body/w:tbl[w:tblPr/w:tblBorders]", namespaces)
      rows = table.xpath("w:tr", namespaces)
      {
        cells: rows.map do |row|
          row.xpath("w:tc", namespaces).map { |cell| cell.xpath(".//w:t", namespaces).text }
        end,
        borders: table.xpath("w:tblPr/w:tblBorders/*/@w:val", namespaces).map(&:value),
        indent: table.at_xpath("w:tblPr/w:tblInd/@w:w", namespaces)&.value,
        span: rows.last.at_xpath("w:tc/w:tcPr/w:gridSpan/@w:val", namespaces)&.value,
        markers: table.xpath(".//w:vertAlign[@w:val='superscript']", namespaces).size,
        document_notes: doc.xpath("//w:footnoteReference", namespaces).size,
        key_paragraphs: doc.xpath("//w:pStyle[@w:val='KeyTitle' or @w:val='KeyText']", namespaces).size,
      }
    end

    let(:expected_formula_key) do
      {
        cells: [["X", "The X coordinatea"], ["Y", "The Y coordinatea"],
                ["a Measured from the origin."]],
        borders: Array.new(6, "single"), indent: "403", span: "2", markers: 3,
        document_notes: 0, key_paragraphs: 0
      }
    end

    let(:unlabelled_formula_key_xml) do
      formula_key_xml.sub('<fn reference="a" target="fn-a"/>',
                          '<fn target="fn-z"><p>Lost body.</p></fn>')
    end
    it "renders two bordered columns with table-local footnotes" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "formula.docx")
        adapter.convert(formula_key_xml, path)
        extract_docx(path) { |doc, ns| expect(formula_key_properties(doc, ns)).to eq(expected_formula_key) }
      end
    end

    def unlabelled_note_bodies(path)
      extract_docx(path) do |doc, namespaces|
        references = doc.xpath("//w:tbl//w:footnoteReference/@w:id", namespaces)
        notes = Zip::File.open(path) { |zip| zip.find_entry("word/footnotes.xml")&.get_input_stream&.read }
        footnotes = Nokogiri::XML(notes).xpath("//w:footnote", namespaces)
        references.map do |id|
          body = footnotes.find { |footnote| footnote["w:id"] == id.value }
          body&.xpath(".//w:t", namespaces)&.text
        end
      end
    end


    it "preserves an unlabelled formula key footnote as a Word footnote" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "formula.docx")
        adapter.convert(unlabelled_formula_key_xml, path)
        expect(unlabelled_note_bodies(path)).to eq([" Lost body."])
      end
    end

    it "records the formula key work status in the rice TODO" do
      todo = File.read(File.expand_path("../../../../TODO.docx/P3-005-e2e-rice-spec.md", __dir__))
      metadata = todo[/\A---\n(.*?)^---$/m, 1]
      expect(metadata).to match(/^status: (?:done|partial)$/)
    end
  end

  describe "general dl rendering (Definition style)" do
    it "renders both dt and dd as Definition outside formula" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <dl>
              <dt>Term1</dt>
              <dd>Definition for term1</dd>
            </dl>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| para_style_value(p) }

        expect(styles).to include("Definition"),
          "expected at least one Definition paragraph, got: #{styles.inspect}"
        expect(styles).not_to include("KeyTitle"),
          "KeyTitle should not appear outside formula zone, got: #{styles.inspect}"
      end
    end
  end

  # Presentation XML keeps the semantic <stem> next to the <fmt-stem>
  # that renders it, so a term walked in document order printed the
  # symbol twice ("ww" for w in the ISO 2533 figure keys).
  describe "a term holding a stem and its fmt-stem" do
    it "renders the symbol once" do
      math = '<math xmlns="http://www.w3.org/1998/Math/MathML"><mi>w</mi></math>'
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <dl>
              <dt><stem type="MathML" id="s1">#{math}<asciimath>w</asciimath></stem><fmt-stem type="MathML"><semx element="stem" source="s1">#{math}<asciimath>w</asciimath></semx></fmt-stem></dt>
              <dd><p>wind speed</p></dd>
            </dl>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir("dt-stem-") do |dir|
        path = File.join(dir, "stem.docx")
        adapter.convert(xml, path)
        raw = Zip::File.open(path) do |zip|
          zip.find_entry("word/document.xml").get_input_stream.read
        end
        doc = Nokogiri::XML(raw)
        ns = doc.collect_namespaces.transform_keys { |k| k.sub("xmlns:", "") }
        term = doc.at_xpath("//w:p[following-sibling::w:p[1][contains(., 'wind speed')]]", ns)
        symbols = term.xpath(".//m:t | .//w:t", ns).map(&:text).join

        expect(symbols).to eq("w")
      end
    end
  end

  # Definition-list terms that are plain text carrying XML-hostile
  # characters must survive into the DOCX output. The isodoc Word
  # (MHTML) path dropped such terms: WordFunction::Body#dt_parse
  # appended dterm.text via Nokogiri Builder#<<, which parses its
  # argument as markup, so a bare "&" or "<" made the insertion invalid
  # and the term cell came out empty (isodoc#898, fixed in isodoc#900
  # by appending as text instead of markup). The uniword path appends
  # text through the typed model (ParagraphBuilder#<<, escaped at
  # serialization), so the same terms must round-trip intact here.
  describe "definition-list term escaping (isodoc#898 consistency)" do
    XML_HOSTILE_TERMS = ["&", "&&", "<", "<<", ">>", "||"].freeze

    def hostile_dl_xml
      dts = XML_HOSTILE_TERMS.each_with_index.map do |term, i|
        "<dt>#{CGI.escapeHTML(term)}</dt><dd>definition #{i}</dd>"
      end.join

      minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Operators</title>
            <dl>#{dts}</dl>
          </clause>
        </sections>
      INNER
    end

    it "renders bare & and < term text in the DOCX paragraphs" do
      convert_and_extract(adapter, hostile_dl_xml) do |pkg|
        texts = pkg.document.body.paragraphs.map do |p|
          Array(p.runs).map { |r| run_text(r) }.join
        end

        XML_HOSTILE_TERMS.each do |term|
          expect(texts).to include(term),
            "term #{term.inspect} lost in DOCX output; paragraphs: " \
            "#{texts.compact.inspect}"
        end
      end
    end

    it "serializes the term text as escaped XML in document.xml" do
      Dir.mktmpdir("dt-escape-") do |dir|
        path = File.join(dir, "escaped.docx")
        adapter.convert(hostile_dl_xml, path)

        raw = Zip::File.open(path) do |zip|
          zip.find_entry("word/document.xml").get_input_stream.read
        end

        # A raw & or < in the stream would make the package unreadable:
        # strict-parse before any content assertions.
        doc = Nokogiri::XML(raw) { |c| c.strict }
        w = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        serialized = doc.xpath("//w:t", w).map(&:text)

        XML_HOSTILE_TERMS.each do |term|
          expect(serialized).to include(term),
            "term #{term.inspect} not present in serialized document.xml"
        end
        expect(raw).to include("&amp;"), "no escaped ampersand serialized"
        expect(raw).to include("&lt;"), "no escaped less-than serialized"
      end
    end
  end

  describe "symbols-clause dl rendering (two-column table)" do
    it "keeps paragraph rendering for a dl inside a plain clause" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Formulas</title>
            <dl>
              <dt>&amp;</dt>
              <dd>bitwise AND</dd>
            </dl>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body

        expect(body.tables).to be_empty,
          "a dl outside the symbols clause must not become a table, " \
          "got: #{body.tables.inspect}"
        styles = body.paragraphs.map { |p| para_style_value(p) }
        expect(styles).to include("Definition")
      end
    end

    it "renders the dl of a definitions section as a two-column table" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <p>Body text.</p>
          </clause>
          <definitions id="d1" displayorder="6">
            <title>Symbols and abbreviated terms</title>
            <dl id="dl1">
              <dt>F</dt>
              <dd>file length in bytes</dd>
              <dt>K</dt>
              <dd>number of source symbols</dd>
            </dl>
          </definitions>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        table = body.tables.find do |tbl|
          cell_text(tbl).include?("file length in bytes")
        end

        expect(table).not_to be_nil,
          "symbols dl should render as a table; body tables: " \
          "#{body.tables.map { |t| cell_text(t) }.inspect}"

        expect(table.rows.size).to eq(2)
        table.rows.each do |row|
          expect(row.cells.size).to eq(2),
            "each symbols row should have a term and a definition cell, " \
            "got #{row.cells.size} cells"
        end

        expect(cell_text(table)).to include("F")
        expect(cell_text(table)).to include("file length in bytes")
        expect(cell_text(table)).to include("K")
        expect(cell_text(table)).to include("number of source symbols")

        # No Definition paragraphs: the dl body moved into the table.
        styles = body.paragraphs.map { |p| para_style_value(p) }
        expect(styles).not_to include("KeyTitle")
      end
    end

    it "styles the symbols table cells with Tablebody" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <definitions id="d1">
            <title>Symbols and abbreviated terms</title>
            <dl id="dl1">
              <dt>F</dt>
              <dd>file length in bytes</dd>
            </dl>
          </definitions>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        table = pkg.document.body.tables
          .find { |tbl| cell_text(tbl).include?("file length in bytes") }

        expect(table).not_to be_nil
        cell_styles = table.rows.flat_map do |row|
          row.cells.flat_map do |cell|
            cell.paragraphs.map { |p| para_style_value(p) }
          end
        end
        expect(cell_styles).to all(eq("Tablebody")),
          "symbols dl cells should use Tablebody, got: #{cell_styles.inspect}"
      end
    end
  end
end
