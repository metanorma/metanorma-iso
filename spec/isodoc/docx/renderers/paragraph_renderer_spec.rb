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
      style_value = plain.properties&.style&.value
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
        style_id = p.properties&.style&.value.to_s
        style_id.start_with?("Heading")
      end
      expect(heading_paras).not_to be_empty,
        "floating-title should produce a Heading* paragraph"
    end
  end
end
