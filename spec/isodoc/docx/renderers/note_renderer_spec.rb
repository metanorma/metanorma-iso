# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::NoteRenderer do
  let(:adapter) { build_adapter }

  it "renders note content inside Box wrappers with Noteindent style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <note id="n1">
            <p>This is a note.</p>
          </note>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Box-begin"),
        "Box-begin should wrap note, got: #{styles.inspect}"
      expect(styles).to include("Noteindent"),
        "note body should use Noteindent, got: #{styles.inspect}"
      expect(styles).to include("Box-end"),
        "Box-end should close note, got: #{styles.inspect}"
    end
  end

  it "does not bleed Noteindent outside the note" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body paragraph before.</p>
          <note id="n1"><p>Note text.</p></note>
          <p>Body paragraph after.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      body = pkg.document.body
      note_index = body.paragraphs.index { |p| p.properties&.style&.value == "Noteindent" }
      box_end_index = body.paragraphs.index { |p| p.properties&.style&.value == "Box-end" }

      expect(note_index).to be_truthy
      expect(box_end_index).to be_truthy
      expect(note_index).to be < box_end_index,
        "Noteindent paragraph should appear before Box-end"
    end
  end

  it "uses Noteindent for the first paragraph and Noteindentcontinued for the rest" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <note id="n1">
            <p>First note paragraph.</p>
            <p>Second note paragraph.</p>
            <p>Third note paragraph.</p>
          </note>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      initial_count = styles.count("Noteindent")
      continued_count = styles.count("Noteindentcontinued")

      expect(initial_count).to eq(1),
        "first paragraph should use Noteindent, got: #{styles.inspect}"
      expect(continued_count).to eq(2),
        "2nd+ paragraphs should use Noteindentcontinued, got: #{styles.inspect}"
    end
  end
end
