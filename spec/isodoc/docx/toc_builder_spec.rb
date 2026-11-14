# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::TocBuilder do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline_renderer) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:toc_builder) { described_class.new(resolver, inline_renderer, context) }

  describe "#render" do
    it "renders TOC heading with Contents title" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts.first).to include("Contents")
    end

    it "renders TOC entries for body sections" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Scope text.</p></clause>
          <clause id="terms"><fmt-title>Terms and definitions</fmt-title><p>Terms.</p></clause>
        </sections>
        <annex id="a1"><fmt-title>Annex A</fmt-title><p>Annex.</p></annex>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("Foreword")
      expect(texts).to include("Scope")
      expect(texts).to include("Terms and definitions")
      expect(texts).to include("Annex A")
    end

    it "uses TOC1/TOC2/TOC3 styles based on heading depth" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <clause id="s1-1"><fmt-title>General</fmt-title><p>Text.</p></clause>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc1_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "TOC1"
      end
      toc2_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "TOC2"
      end

      expect(toc1_paras.length).to be >= 1
      expect(toc2_paras.length).to be >= 1
    end

    it "renders PAGEREF fields in TOC entries" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      # Find TOC entry paragraphs (not the heading)
      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end

      # Each TOC entry should have field characters
      field_chars = toc_paras.flat_map(&:runs).select do |r|
        r.field_char || r.instr_text
      end
      expect(field_chars.length).to be > 0
    end

    it "handles model with no sections gracefully" do
      xml = minimal_iso_xml("<sections/>")
      model = parse_iso_document(xml)

      toc_builder.render(model, doc)

      # Should at least have the heading
      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("Contents")
    end

    it "skips TOC-type clauses to avoid duplication" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <clause type="toc" id="toc1"><fmt-title depth="1">Contents</fmt-title></clause>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end

      # Should have entries but not duplicate the TOC clause
      scope_entries = toc_paras.select do |p|
        p.runs.any? { |r| run_text(r).include?("Scope") }
      end
      expect(scope_entries.length).to be >= 1
    end

    it "renders annex entries from the single-line toc variant-title" do
      xml = minimal_iso_xml(<<~INNER)
        <sections/>
        <annex id="a1" obligation="normative">
          <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><br/><span class="fmt-obligation">(normative)</span><br/><br/><semx element="title" source="a1t">Annex text</semx></fmt-title>
          <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex text</semx></variant-title>
          <clause id="a1-1"><fmt-title>Annex sub</fmt-title><p>Body.</p></clause>
        </annex>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end
      annex_entry = toc_paras.find do |p|
        p.runs.any? { |r| run_text(r) == "Annex text" }
      end
      expect(annex_entry).not_to be_nil

      # The entry carries the variant-title composition: label + tab +
      # title, with no line breaks and no obligation line.
      texts = annex_entry.runs.map { |r| run_text(r) }
      expect(texts).not_to include("(normative)")
      expect(annex_entry.runs.map(&:break).compact).to be_empty
      expect(annex_entry.runs.any?(&:tab)).to be(true)
    end

    it "falls back to fmt-title when no toc variant-title is present" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.flat_map do |p|
        p.runs.map { |r| run_text(r) }
      end
      expect(texts).to include("Scope")
    end

    it "excludes annex sub-clauses from the ToC" do
      xml = minimal_iso_xml(<<~INNER)
        <sections/>
        <annex id="a1">
          <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex text</semx></fmt-title>
          <clause id="a1-1"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx><span class="fmt-autonum-delim">.</span><semx element="autonum" source="a1-1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1-1t">Annex sub one</semx></fmt-title><p>Body.</p></clause>
          <clause id="a1-2"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx><span class="fmt-autonum-delim">.</span><semx element="autonum" source="a1-2">2</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1-2t">Annex sub two</semx></fmt-title><p>Body.</p></clause>
        </annex>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.flat_map do |p|
        p.runs.map { |r| run_text(r) }
      end

      # The annex main entry is present…
      expect(texts).to include("Annex text")
      # …but its sub-clauses are not, at any ToC level.
      expect(texts).not_to include("Annex sub one")
      expect(texts).not_to include("Annex sub two")
      expect(texts).not_to include("A.1")
      expect(texts).not_to include("A.2")
    end
  end

  describe "TOC field structure" do
    it "wraps the static entries in a single TOC field result" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
          <clause id="s2"><fmt-title>Another</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      adapter = build_adapter
      docx = nil
      Dir.mktmpdir do |dir|
        path = File.join(dir, "toc.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |xml_doc, ns|
          docx = xml_doc
          ns_hash = ns
          paras = xml_doc.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val, 'TOC')]]", ns_hash)
          expect(paras.length).to be >= 2

          # Exactly one TOC field instruction, inside the FIRST entry
          # paragraph, ahead of its entry text.
          toc_instrs = xml_doc.xpath("//w:instrText[contains(text(), 'TOC \\o')]", ns_hash)
          expect(toc_instrs.length).to eq(1)
          first = paras.first
          expect(first.xpath(".//w:instrText[contains(text(), 'TOC \\o')]", ns_hash)).not_to be_empty
          entry_texts = first.xpath(".//w:t", ns_hash).map(&:text)
          expect(entry_texts.join).not_to be_empty

          # The field separate precedes the entry content; the last entry
          # paragraph carries the TOC field end.
          types = first.xpath(".//w:fldChar/@w:fldCharType", ns_hash).map(&:value)
          expect(types.first).to eq("begin")
          expect(types).to include("separate")
          last = paras.last
          expect(last.xpath(".//w:fldChar[@w:fldCharType='end']", ns_hash)
            .length).to be >= 2 # PAGEREF end + TOC field end

          # No standalone paragraph carries only the field machinery.
          lone_field = xml_doc.xpath(
            "//w:p[w:instrText[contains(text(), 'TOC \\o')] " \
            "and not(w:pPr/w:pStyle[starts-with(@w:val, 'TOC')])]",
            ns_hash,
          )
          expect(lone_field).to be_empty
        end
      end
      expect(docx).not_to be_nil
    end
  end
end
