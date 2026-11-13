# frozen_string_literal: true

require_relative "../spec_helper"

# Specs for InlineRenderers handler classes not covered by
# handlers_spec.rb (which focuses on the original 9: italic, bold,
# sub, sup, break, tab, null, bookmark, bcp14, keyword).
#
# These specs exercise each handler in isolation by constructing it
# with a real InlineRenderer as parent (the production wiring) and
# feeding it real model instances parsed from XML snippets.
RSpec.describe IsoDoc::Iso::Docx::InlineRenderers do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:parent) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }

  def build_para
    Uniword::Builder::ParagraphBuilder.new
  end

  def first_inline_in(paragraph)
    parent.each_ordered_element(paragraph) do |type, obj|
      return obj if type == :element
    end
    raise "no inline element child found in paragraph"
  end

  def parse_first_inline(xml_fragment)
    xml = minimal_iso_xml(
      "<sections><clause id='c'><p>#{xml_fragment}</p></clause></sections>",
    )
    element = parse_iso_document(xml).sections.clause.first.paragraphs.first
    first_inline_in(element)
  end

  def parse_standalone_element(klass, xml_fragment)
    klass.from_xml(xml_fragment)
  end

  # ── Run-format handlers (parallel to italic/bold) ─────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::StrikethroughRenderer do
    it "renders a StrikeElement as a strikethrough run" do
      strike = parse_first_inline("<strike>removed</strike>")
      para = build_para
      described_class.new(parent).render(strike, para)

      run = para.build.runs.first
      expect(run.properties.strike).to be_a(Uniword::Properties::Strike)
      expect(run.text).to eq("removed")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::UnderlineRenderer do
    it "renders an UnderlineElement as an underline run" do
      underline = parse_first_inline("<underline>stressed</underline>")
      para = build_para
      described_class.new(parent).render(underline, para)

      run = para.build.runs.first
      expect(run.properties.underline).to be_a(Uniword::Properties::Underline)
      expect(run.text).to eq("stressed")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::MonospaceRenderer do
    it "renders a TtElement as a run with the InlineCode character style" do
      tt = parse_first_inline("<tt>code()</tt>")
      para = build_para
      described_class.new(parent).render(tt, para)

      style_value = para.build.runs.first.properties.style.value
      expect(style_value).to eq(resolver.character_style(:inline_code))
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::SmallCapRenderer do
    it "renders a SmallCapElement as a small-caps run" do
      smallcap = parse_first_inline("<smallcap>Acronym</smallcap>")
      para = build_para
      described_class.new(parent).render(smallcap, para)

      run = para.build.runs.first
      expect(run.properties.small_caps).to be_a(Uniword::Properties::SmallCaps)
      expect(run.text).to eq("Acronym")
    end
  end

  # ── Hyperlink handlers ─────────────────────────────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::LinkRenderer do
    it "renders a LinkElement as a Hyperlink-styled external hyperlink" do
      link = parse_first_inline('<link target="https://example.com">site</link>')
      para = build_para
      described_class.new(parent).render(link, para)

      built = para.build
      expect(built.hyperlinks.length).to eq(1)
      link_model = built.hyperlinks.first
      expect(link_model.runs.first.properties.style.value)
        .to eq(resolver.character_style(:hyperlink))
    end

    it "uses the target URL as text when no visible text is present" do
      link = parse_first_inline('<link target="https://example.com"/>')
      para = build_para
      described_class.new(parent).render(link, para)

      link_model = para.build.hyperlinks.first
      expect(link_model.runs.map(&:text).join).to eq("https://example.com")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::XrefRenderer do
    it "renders an XrefElement as an internal-anchor hyperlink" do
      xref = parse_first_inline('<xref target="sec1">Section 1</xref>')
      para = build_para
      described_class.new(parent).render(xref, para)

      link_model = para.build.hyperlinks.first
      expect(link_model.anchor).to eq("sec1")
      expect(link_model.runs.map(&:text).join).to eq("Section 1")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::ErefRenderer do
    it "renders an ErefElement as a hyperlink whose URL is the cite key" do
      eref = parse_first_inline('<eref citeas="ISO1234">[1]</eref>')
      para = build_para
      described_class.new(parent).render(eref, para)

      link_model = para.build.hyperlinks.first
      expect(link_model.runs.map(&:text).join).to eq("[1]")
    end
  end

  # ── Footnote handler (caches by identity) ──────────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::FootnoteRenderer do
    it "renders a FnElement as a footnote reference run" do
      fn = parse_first_inline("<fn target='fn1'><p id='fp1'>Note.</p></fn>")
      para = build_para
      described_class.new(parent).render(fn, para)

      run = para.build.runs.first
      expect(run.footnote_reference).to be_a(Uniword::Wordprocessingml::FootnoteReference)
    end

    it "de-duplicates subsequent references to the same footnote target" do
      fn = parse_first_inline("<fn target='shared'><p id='fp1'>Shared.</p></fn>")
      renderer = described_class.new(parent)
      first_para = build_para
      second_para = build_para
      renderer.render(fn, first_para)
      renderer.render(fn, second_para)

      first_id = first_para.build.runs.first.footnote_reference.id
      second_id = second_para.build.runs.first.footnote_reference.id
      expect(second_id).to eq(first_id)
    end
  end

  # ── Span handler (class-based style dispatch) ──────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::SpanRenderer do
    it "renders a SpanElement with mixed content via fallback walk" do
      span = parse_first_inline("<span>just text</span>")
      para = build_para
      described_class.new(parent).render(span, para)

      expect(para.build.runs.map(&:text).join).to eq("just text")
    end
  end

  # ── Semx handler (autonum / link skipping) ────────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::SemxRenderer do
    it "renders a SemxElement with plain text content" do
      semx = parse_first_inline("<semx element='term'>cargo</semx>")
      para = build_para
      described_class.new(parent).render(semx, para)

      expect(para.build.text).to eq("cargo")
    end
  end

  # ── Callout handler (superscript "(N)" run) ───────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::CalloutRenderer do
    it "renders a Callout as a superscript parenthesized run" do
      callout = parse_standalone_element(
        Metanorma::Document::Components::ReferenceElements::Callout,
        "<callout target='c1'>1</callout>",
      )
      para = build_para
      described_class.new(parent).render(callout, para)

      run = para.build.runs.first
      expect(run.properties.vertical_align.value).to eq("superscript")
      expect(run.text).to eq("(1)")
    end
  end

  # ── Asciimath handler (text + Stem style) ──────────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::AsciimathRenderer do
    it "renders an AsciimathElement as a text run" do
      asc = parse_standalone_element(
        Metanorma::Document::Components::Inline::AsciimathElement,
        "<asciimath>x^2</asciimath>",
      )
      para = build_para
      described_class.new(parent).render(asc, para)

      expect(para.build.runs.first.text).to eq("x^2")
    end
  end

  # ── MixedInlineFallback handler (walking children) ────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::MixedInlineFallbackRenderer do
    it "walks a ParagraphBlock's mixed content in document order" do
      xml = minimal_iso_xml(
        "<sections><clause id='c'><p>before <em>mid</em> after</p></clause></sections>",
      )
      paragraph = parse_iso_document(xml).sections.clause.first.paragraphs.first

      para = build_para
      described_class.new(parent).render(paragraph, para)

      expect(para.build.text).to eq("before mid after")
    end
  end

  # ── Term delegation handlers ───────────────────────────────────────

  describe IsoDoc::Iso::Docx::InlineRenderers::TermNameRenderer do
    it "renders a TermNameElement by delegating to parent.render" do
      xml = minimal_iso_xml(
        "<sections><terms><term><preferred><expression><name>Rice</name></expression></preferred></term></terms></sections>",
      )
      term = parse_iso_document(xml).sections.terms.term.first
      name = term.preferred.first.expression.name.first

      para = build_para
      described_class.new(parent).render(name, para)

      expect(para.build.text).to eq("Rice")
    end
  end

  describe IsoDoc::Iso::Docx::InlineRenderers::TermExpressionRenderer do
    it "walks each name child of a TermExpression in order" do
      xml = minimal_iso_xml(
        "<sections><terms><term><preferred><expression><name>Rice</name></expression></preferred></term></terms></sections>",
      )
      expression = parse_iso_document(xml)
                         .sections.terms.term.first.preferred.first.expression

      para = build_para
      described_class.new(parent).render(expression, para)

      expect(para.build.text).to eq("Rice")
    end
  end
end
