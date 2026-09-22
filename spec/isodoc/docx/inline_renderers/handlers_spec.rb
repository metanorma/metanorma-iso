# frozen_string_literal: true

require_relative "../spec_helper"

# Specs for the InlineRenderers handler classes. Each handler is a small
# class that renders one kind of model element into a ParagraphBuilder.
# These specs exercise handlers in isolation by constructing them with
# a real InlineRenderer as parent (the production wiring).
RSpec.describe IsoDoc::Iso::Docx::InlineRenderers do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:parent) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }

  def build_para
    Uniword::Builder::ParagraphBuilder.new
  end

  def para_text(para)
    para.build.text
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::ItalicRenderer do
    it "renders an EmRawElement as an italic run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p><em>italic</em></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      em = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(em, para)

      built = para.build
      expect(built.runs.first.properties.italic).to be_a(Uniword::Properties::Italic)
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::BoldRenderer do
    it "renders a StrongRawElement as a bold run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p><strong>bold</strong></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      strong = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(strong, para)

      built = para.build
      expect(built.runs.first.properties.bold).to be_a(Uniword::Properties::Bold)
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::SubscriptRenderer do
    it "renders a SubElement as a subscript run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p>H<sub>2</sub>O</p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      sub = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(sub, para)

      built = para.build
      expect(built.runs.first.properties.vertical_align.value).to eq("subscript")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::SuperscriptRenderer do
    it "renders a SupElement as a superscript run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p>x<sup>2</sup></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      sup = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(sup, para)

      built = para.build
      expect(built.runs.first.properties.vertical_align.value).to eq("superscript")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::BreakRenderer do
    it "appends a break run to the paragraph" do
      element = make_textless_element
      para = build_para
      described_class.new(parent).render(element, para)

      built = para.build
      expect(built.runs.first.break).to be_a(Uniword::Wordprocessingml::Break)
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::TabRenderer do
    it "appends a tab run to the paragraph" do
      element = make_textless_element
      para = build_para
      described_class.new(parent).render(element, para)

      built = para.build
      expect(built.runs.first.tab).to be_a(Uniword::Wordprocessingml::Tab)
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::NullRenderer do
    it "returns nil and has no side effect on the paragraph" do
      element = make_textless_element
      para = build_para
      result = described_class.new(parent).render(element, para)
      expect(result).to be_nil
      expect(para.build.runs).to be_empty
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::BookmarkRenderer do
    it "appends a bookmark start and end pair with the element's id" do
      xml = minimal_iso_xml("<sections><clause id='c'><p>Text <bookmark id='bm1'/></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      bookmark = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(bookmark, para)

      built = para.build
      expect(built.bookmark_starts.length).to eq(1)
      expect(built.bookmark_ends.length).to eq(1)
      expect(built.bookmark_starts.first.name).to eq("bm1")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::Bcp14Renderer do
    it "renders BCP 14 content as a bold run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p><bcp14>MUST</bcp14></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      bcp14 = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(bcp14, para)

      built = para.build
      expect(built.runs.first.properties.bold).to be_a(Uniword::Properties::Bold)
      expect(built.text).to eq("MUST")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::KeywordRenderer do
    it "renders a keyword as a bold small-caps run" do
      xml = minimal_iso_xml("<sections><clause id='c'><p><keyword>SAMPLE</keyword></p></clause></sections>")
      element = parse_iso_document(xml).sections.clause.first.paragraphs.first
      keyword = walk_to_first_inline(element)

      para = build_para
      described_class.new(parent).render(keyword, para)

      built = para.build
      expect(built.runs.first.properties.bold).to be_a(Uniword::Properties::Bold)
      expect(built.runs.first.properties.small_caps).to be_a(Uniword::Properties::SmallCaps)
    end
  end

  # Walk into a paragraph's element_order to find its first inline child
  # (em, strong, sub, sup, etc.). This mirrors what dispatch_inline does
  # in production: each child of a paragraph is visited in order.
  def walk_to_first_inline(paragraph)
    parent.each_ordered_element(paragraph) do |type, obj|
      return obj if type == :element
    end
    raise "no inline element child found in paragraph"
  end

  # A minimal stand-in element for handlers that ignore their input
  # (BreakRenderer, TabRenderer, NullRenderer). Uses a Struct so the
  # object is opaque from the handler's perspective.
  def make_textless_element
    Struct.new(:placeholder).new(nil)
  end
end
