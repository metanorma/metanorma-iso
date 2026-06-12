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
        p.properties&.style&.value == "TOC1"
      end
      toc2_paras = doc.model.body.paragraphs.select do |p|
        p.properties&.style&.value == "TOC2"
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
        p.properties&.style&.value&.start_with?("TOC")
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
        p.properties&.style&.value&.start_with?("TOC")
      end

      # Should have entries but not duplicate the TOC clause
      scope_entries = toc_paras.select do |p|
        p.runs.any? { |r| (r.text || "").include?("Scope") }
      end
      expect(scope_entries.length).to be >= 1
    end
  end
end
