# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ParagraphRenderer do
  let(:adapter) { build_adapter }

  it "renders a plain paragraph in the default body zone without an explicit rstyle" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>A plain body paragraph.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      plain = pkg.document.body.paragraphs.find do |p|
        p.runs.any? { |r| r.text.to_s.include?("A plain body paragraph") }
      end
      expect(plain).not_to be_nil
      # Era C body text uses the document default; no rStyle is required.
      style_value = para_style_value(plain)
      expect(style_value).to be_nil.or eq("Bodytext")
    end
  end

  it "skips paragraphs with class zzSTDTitle (cover title duplicates)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p class="zzSTDTitle">Spurious cover title</p>
          <p>Real body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.flat_map { |p| p.runs.map(&:text) }
      expect(texts.join).not_to include("Spurious cover title"),
        "zzSTDTitle paragraph should be suppressed"
    end
  end

  it "applies explicit alignment when present" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p align="center">Centered text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      centered = pkg.document.body.paragraphs.find do |p|
        p.runs.any? { |r| r.text.to_s.include?("Centered text") }
      end
      expect(centered).not_to be_nil
      align = centered.properties&.alignment&.value
      expect(align).to eq("center"),
        "align=center should map to paragraph alignment center, got: #{align.inspect}"
    end
  end

  it "renders floating-title paragraphs with heading style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p type="floating-title" depth="2">Sub-heading</p>
          <p>Body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        style_id = para_style_value(p).to_s
        style_id.start_with?("Heading")
      end
      expect(heading_paras).not_to be_empty,
        "floating-title should produce a Heading* paragraph"
    end
  end

  it "splits a paragraph with an embedded <note> into siblings" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">Split Note</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p id="p1">Body text before note.<note id="n1"><p id="np1">Lower mass fractions of moisture are sometimes needed.</p></note></p>
          <p id="p2">Body paragraph after.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paragraphs = pkg.document.body.paragraphs
      body_texts = paragraphs.map { |p| p.runs.map(&:text).join }
      joined = body_texts.join

      # Inline content before the note is preserved.
      expect(joined).to include("Body text before note."),
        "text before embedded note should be rendered"
      # Sibling paragraph after the note is preserved.
      expect(joined).to include("Body paragraph after."),
        "sibling paragraph after embedded note should be rendered"
      # The note's body text is rendered (not silently dropped).
      expect(joined).to include("Lower mass fractions of moisture"),
        "embedded note body text should be rendered"

      # The note is Box-wrapped: a Box-begin paragraph precedes the
      # Noteindent body, and a Box-end paragraph follows it.
      styles = paragraphs.map { |p| para_style_value(p).to_s }
      expect(styles).to include("Box-begin"),
        "embedded note should be wrapped in Box-begin"
      expect(styles).to include("Noteindent"),
        "embedded note body should use Noteindent style"
      expect(styles).to include("Box-end"),
        "embedded note should be wrapped in Box-end"
    end
  end
end
