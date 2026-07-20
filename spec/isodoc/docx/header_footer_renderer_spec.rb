# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::HeaderFooterRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:renderer) { described_class.new(resolver) }

  # Build a minimal part content with paragraphs collection, matching the
  # shape of HeaderFooterPart#content used by SectionManager.
  let(:part_content) { Struct.new(:paragraphs).new([]) }

  describe "#render_header" do
    it "produces a HeaderCentered paragraph with bold right-aligned text" do
      renderer.render_header(part_content, "ISO/CD 17301-1:2016(en)")

      para = part_content.paragraphs.first
      expect(para).not_to be_nil

      style_value = para_style_value(para)
      expect(style_value).to eq("HeaderCentered"),
        "header should use HeaderCentered style, got: #{style_value.inspect}"

      alignment = para.properties&.alignment&.value
      expect(alignment).to eq("right")

      text = para.runs.map(&:text).join
      expect(text).to include("ISO/CD 17301-1:2016(en)")

      bold = para.runs.first&.properties&.bold&.value
      expect(bold).to be(true), "header run should be bold"
    end

    it "clears any prior content in the part" do
      part_content.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      renderer.render_header(part_content, "Title")

      expect(part_content.paragraphs.length).to eq(1)
    end
  end

  describe "#render_footer with roman scheme" do
    let(:scheme) { IsoDoc::Iso::Docx::PageScheme.roman }

    it "uses FooterPageRomanNumber style" do
      renderer.render_footer(part_content, "© ISO 2016", scheme: scheme)

      para = part_content.paragraphs.first
      style_value = para_style_value(para)
      expect(style_value).to eq("FooterPageRomanNumber"),
        "roman footer should use FooterPageRomanNumber, got: #{style_value.inspect}"
    end

    it "embeds the page-number field as run-wrapped fldChars" do
      renderer.render_footer(part_content, "© ISO 2016", scheme: scheme)

      para = part_content.paragraphs.first
      field_types = para.runs.map { |r| r.field_char&.fldCharType }.compact
      expect(field_types).to eq(%w[begin separate end]),
        "footer must contain a complete PAGE field, got: #{field_types.inspect}"
    end

    it "wraps each fldChar in a dedicated <w:r> run (schema requirement)" do
      renderer.render_footer(part_content, "© ISO 2016", scheme: scheme)

      para = part_content.paragraphs.first
      # Every field_char must be inside its own run, never a direct child of <w:p>.
      para.runs.each do |r|
        if r.field_char
          # The run must be the SOLE carrier of that field_char (no extra runs to break field).
          expect(r.text).to be_nil.or(eq(""))
          expect(r.tab).to be_nil
        end
      end
      # And no field_chars at the paragraph level (old broken structure).
      expect(para.respond_to?(:field_chars) ? para.field_chars : []).to be_empty
    end

    it "places the PAGE instrText inside its own run between begin and separate" do
      renderer.render_footer(part_content, "© ISO 2016", scheme: scheme)

      para = part_content.paragraphs.first
      instr_runs = para.runs.select { |r| r.instr_text }
      expect(instr_runs.length).to eq(1),
        "PAGE field needs exactly one instrText run, got #{instr_runs.length}"

      instr_text = instr_runs.first.instr_text.text
      expect(instr_text).to include("PAGE"),
        "instrText must include PAGE, got: #{instr_text.inspect}"
    end

    it "places the copyright text and tab before the field" do
      renderer.render_footer(part_content, "© ISO 2016", scheme: scheme)

      para = part_content.paragraphs.first
      first_run_text = para.runs.first.text
      expect(first_run_text).to include("© ISO 2016")
      expect(para.runs.any? { |r| !r.tab.nil? }).to be(true),
        "footer must include a tab run between text and page number"
    end
  end

  describe "#render_footer with arabic scheme" do
    let(:scheme) { IsoDoc::Iso::Docx::PageScheme.arabic }

    it "uses FooterPageNumber style" do
      renderer.render_footer(part_content, "© ISO 2024", scheme: scheme)

      para = part_content.paragraphs.first
      style_value = para_style_value(para)
      expect(style_value).to eq("FooterPageNumber"),
        "arabic footer should use FooterPageNumber, got: #{style_value.inspect}"
    end

    it "embeds the page-number field as run-wrapped fldChars" do
      renderer.render_footer(part_content, "© ISO 2024", scheme: scheme)

      para = part_content.paragraphs.first
      field_types = para.runs.map { |r| r.field_char&.fldCharType }.compact
      expect(field_types).to eq(%w[begin separate end])
    end
  end
end
