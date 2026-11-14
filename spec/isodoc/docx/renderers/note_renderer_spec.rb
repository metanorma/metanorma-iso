# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::NoteRenderer do
  let(:adapter) { build_adapter }

  it "runs the NOTE label inline at the head of the first body paragraph" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <note id="n1">
            <fmt-name>NOTE 1</fmt-name>
            <p>This is a note.</p>
          </note>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs
      note_para = paras.find { |p| para_style_value(p) == "Noteindent" }

      expect(note_para).not_to be_nil,
        "note body should use Noteindent, got: #{paras.map { |p| para_style_value(p) }.inspect}"

      texts = note_para.runs.map { |r| run_text(r) }.join
      expect(texts).to start_with("NOTE"),
        "the NOTE label should run inline in the first body paragraph, got: #{texts.inspect}"
      expect(texts).to include("This is a note."),
        "the note body should continue on the same paragraph, got: #{texts.inspect}"
    end
  end

  it "does not draw Era C boxes around notes" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body paragraph before.</p>
          <note id="n1"><fmt-name>NOTE 1</fmt-name><p>Note text.</p></note>
          <p>Body paragraph after.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).not_to include("Box-begin"),
        "notes must not be wrapped in Box-begin (XSL inline-label contract)"
      expect(styles).not_to include("Box-title"),
        "notes must not carry a Box-title paragraph (label runs inline)"
      expect(styles).not_to include("Box-end"),
        "notes must not be wrapped in Box-end"
    end
  end

  it "keeps 2nd+ note paragraphs in the note zone (Noteindentcontinued)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <note id="n1">
            <fmt-name>NOTE 1</fmt-name>
            <p>First note paragraph.</p>
            <p>Second note paragraph.</p>
            <p>Third note paragraph.</p>
          </note>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
      initial_count = styles.count("Noteindent")
      continued_count = styles.count("Noteindentcontinued")

      expect(initial_count).to eq(1),
        "label-carrying first paragraph should use Noteindent, got: #{styles.inspect}"
      expect(continued_count).to eq(2),
        "2nd+ paragraphs should use Noteindentcontinued, got: #{styles.inspect}"
    end
  end

  it "does not bleed the note zone outside the note" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body paragraph before.</p>
          <note id="n1"><fmt-name>NOTE 1</fmt-name><p>Note text.</p></note>
          <p>Body paragraph after.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs
      styles = paras.map { |p| para_style_value(p) }
      note_index = styles.index("Noteindent")
      after = paras[note_index + 1..]

      expect(after.map { |p| para_style_value(p) }).not_to include("Noteindentcontinued"),
        "Noteindentcontinued must not leak past the note"
    end
  end

  it "falls back to a keep-with-next label paragraph when the first child is not a paragraph" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <note id="n1">
            <fmt-name>NOTE 1</fmt-name>
            <ol>
              <li>listed note content</li>
            </ol>
          </note>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs
      labels = paras.select { |p| p.runs.any? { |r| run_text(r).start_with?("NOTE") } }

      expect(labels).not_to be_empty, "the NOTE label should still be rendered"
      label_para = labels.first
      body_text = label_para.runs.map { |r| run_text(r) }.join
      expect(body_text.strip).to eq("NOTE 1"),
        "label paragraph should carry only the label when the first child is a list, got: #{body_text.inspect}"
    end
  end
end
