# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::DefinitionSectionRenderer do
  let(:adapter) { build_adapter }

  it "renders the definitions section title as Heading1, like a clause" do
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
          </dl>
        </definitions>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_styles = pkg.document.body.paragraphs
        .select { |p| para_style_value(p).to_s.start_with?("Heading") }
        .map { |p| para_style_value(p) }

      expect(heading_styles).to include("Heading1"),
                                "definitions section title should use Heading1 like any " \
                                "top-level clause, got: #{heading_styles.inspect}"
    end
  end

  it "carries the section title text in the heading paragraph" do
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
      heading_text = pkg.document.body.paragraphs
        .select { |p| para_style_value(p).to_s.start_with?("Heading") }
        .flat_map { |p| p.runs.map { |r| run_text(r) } }
        .join

      expect(heading_text).to include("Symbols and abbreviated terms"),
                              "the symbols heading must be present in the body, got: " \
                              "#{heading_text.inspect}"
    end
  end

  it "walks the dl children into a table after the heading" do
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
      body = pkg.document.body
      table = body.tables.find do |tbl|
        tbl_text = tbl.rows.flat_map do |row|
          row.cells.flat_map do |cell|
            cell.paragraphs.flat_map { |p| p.runs.map { |r| run_text(r) } }
          end
        end.join
        tbl_text.include?("file length in bytes")
      end

      expect(table).not_to be_nil,
                           "dl inside a definitions section should render as a table"
    end
  end

  it "restores section depth after the section" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <definitions id="d1">
          <title>Symbols and abbreviated terms</title>
          <dl id="dl1">
            <dt>F</dt>
            <dd>file length in bytes</dd>
          </dl>
        </definitions>
        <clause id="c1">
          <title>Formulas</title>
          <p>Body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_styles = pkg.document.body.paragraphs
        .select { |p| para_style_value(p).to_s.start_with?("Heading") }
        .map { |p| para_style_value(p) }

      expect(heading_styles).to eq(%w[Heading1 Heading1]),
                                "the clause following a definitions section should stay at " \
                                "Heading1, got: #{heading_styles.inspect}"
    end
  end
end
