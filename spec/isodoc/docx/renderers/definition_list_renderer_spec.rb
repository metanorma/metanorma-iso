# frozen_string_literal: true

require_relative "../spec_helper"

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

  describe "formula-zone dl rendering (KeyTitle + KeyText)" do
    it "renders dt as KeyTitle and dd as KeyText inside <formula>" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><mo>=</mo><mi>y</mi></math></stem>
              <dl>
                <dt>X</dt>
                <dd>The X coordinate</dd>
                <dt>Y</dt>
                <dd>The Y coordinate</dd>
              </dl>
            </formula>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| para_style_value(p) }

        expect(styles).to include("KeyTitle"),
          "expected at least one KeyTitle paragraph, got: #{styles.inspect}"
        expect(styles).to include("KeyText"),
          "expected at least one KeyText paragraph, got: #{styles.inspect}"
      end
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
  end

  describe "symbols-clause dl rendering (two-column table)" do
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
