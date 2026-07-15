# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# Validates adapter DOCX output against real mn-samples-iso reference documents.
#
# Each sample has:
#   - *.presentation.xml — presentation XML input (required)
#   - *.docx            — reference DOCX from old isodoc converter (optional)
#   - *.doc             — reference MHT from old isodoc converter (optional)
#
# Validation levels:
#   1. Structural — output is a valid DOCX (all documents)
#   2. Content    — key phrases from presentation XML appear in output (all documents)
#   3. Reference  — paragraph count comparable to reference DOCX (documents with reference DOCX)
#   4. Structural detail — styles, tables, specific formatting (select documents)
RSpec.describe "DOCX sample validation" do
  FIXTURES = File.expand_path("../../fixtures/samples", __dir__)

  def generate_adapter_output(pres_xml_path, template: :dis)
    adapter = build_adapter(template: template)
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "adapter-output.docx")
      adapter.convert(pres_xml_path, output_path)
      yield output_path, adapter
    end
  end

  def extract_paragraph_texts(docx_path)
    pkg = Uniword::Docx::Package.from_file(docx_path)
    pkg.document.body.paragraphs.map do |p|
      (p.runs rescue []).map { |r| r.text rescue "" }.join
    end
  end

  def expect_content_present(paragraph_texts, phrases)
    all_text = paragraph_texts.join(" ")
    missing = phrases.reject { |phrase| all_text.include?(phrase) }
    expect(missing).to be_empty,
                       "Missing content in output: #{missing.inspect}"
  end

  def find_paragraph_by_text(paragraphs, text)
    paragraphs.find do |p|
      (p.runs rescue []).map { |r| r.text rescue "" }.join == text
    end
  end

  # ── International Standard: rice-2023 DIS ────────────────────────

  describe "international-standard/rice-2023 DIS" do
    let(:pres_xml) { File.join(FIXTURES, "international-standard/document-en.dis.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "international-standard/document-en.dis.docx") }

    it "generates a valid DOCX from DIS presentation XML" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.exist?(output_path)).to be(true)
        expect(File.size(output_path)).to be > 1000

        pkg = Uniword::Docx::Package.from_file(output_path)
        expect(pkg.document).not_to be_nil
        expect(pkg.document.body).not_to be_nil
      end
    end

    it "contains key cover page content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "ISO/DIS 17301-1",
          "2023-02-01",
        ])
      end
    end

    it "contains copyright and boilerplate content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        all_text = texts.join(" ")
        expect(all_text).to match(/ISO[[:space:]]+2023/)
        expect_content_present(texts, [
          "All rights reserved",
          "Published in Switzerland",
        ])
      end
    end

    it "contains foreword and introduction content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "International Organization for Standardization",
          "third edition",
        ])
      end
    end

    it "contains scope and body content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Scope",
          "minimum specifications for rice",
          "Terms and definitions",
        ])
      end
    end

    it "contains term definitions" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "paddy rice",
          "husked rice",
          "milled rice",
        ])
      end
    end

    it "contains annexes" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Annex A",
          "Determination of defects",
          "Annex B",
          "Annex C",
          "Annex D",
        ])
      end
    end

    it "contains bibliography entries" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "ISO 712",
          "ISO 7301",
        ])
      end
    end

    it "renders tables" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        pkg = Uniword::Docx::Package.from_file(output_path)
        tables = pkg.document.body.tables
        expect(tables.size).to be >= 2
      end
    end

    it "applies paragraph styles" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        pkg = Uniword::Docx::Package.from_file(output_path)
        paras = pkg.document.body.paragraphs

        contents = find_paragraph_by_text(paras, "Contents")
        expect(contents).not_to be_nil
        expect(contents.properties&.style&.value).to eq("zzContents")

        foreword = find_paragraph_by_text(paras, "Foreword")
        expect(foreword).not_to be_nil
        expect(foreword.properties&.style&.value).to eq("ForewordTitle")
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be_between(0.5, 1.5),
                           "Adapter: #{adapter_texts.size} non-empty paragraphs, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── International Standard: rice-2023 WD ─────────────────────────

  describe "international-standard/rice-2023 WD" do
    let(:pres_xml) { File.join(FIXTURES, "international-standard/document-en.wd.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "international-standard/document-en.wd.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml, template: :simple) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Terms and definitions",
        ])
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml, template: :simple) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be_between(0.5, 1.5),
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── International Standard: rice-2023 final ──────────────────────

  describe "international-standard/rice-2023 final" do
    let(:pres_xml) { File.join(FIXTURES, "international-standard/document-en.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "international-standard/document-en.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Bibliography",
        ])
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be_between(0.5, 1.5),
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── Amendment: rice-2023 DAMD ───────────────────────────────────

  describe "amendment/rice-2023 DAMD" do
    let(:pres_xml) { File.join(FIXTURES, "amendment/document-en.damd.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "amendment/document-en.damd.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "AMENDMENT",
          "All rights reserved",
          "Replace",
          "Add the following",
        ])
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be >= 0.7,
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── Amendment: rice-2023 final ──────────────────────────────────

  describe "amendment/rice-2023 final" do
    let(:pres_xml) { File.join(FIXTURES, "amendment/document-en.final.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "amendment/document-en.final.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "AMENDMENT",
          "All rights reserved",
          "Replace",
        ])
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be >= 0.7,
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── Amendment: rice-2023 WD ─────────────────────────────────────

  describe "amendment/rice-2023 WD" do
    let(:pres_xml) { File.join(FIXTURES, "amendment/document-en.wd.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "amendment/document-en.wd.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml, template: :simple) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "AMENDMENT",
          "Warning for WDs and CDs",
          "Replace",
        ])
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml, template: :simple) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be >= 0.7,
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── Technical Report ─────────────────────────────────────────────

  describe "technical-report" do
    let(:pres_xml) { File.join(FIXTURES, "technical-report/document.presentation.xml") }
    let(:reference_docx) { File.join(FIXTURES, "technical-report/document.docx") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect(texts.any? { |t| t.length > 20 }).to be(true),
          "Expected some substantial content in output"
      end
    end

    it "has comparable paragraph count to reference" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        adapter_texts = extract_paragraph_texts(output_path).reject(&:empty?)
        ref_texts = extract_paragraph_texts(reference_docx).reject(&:empty?)
        ratio = adapter_texts.size.to_f / ref_texts.size
        expect(ratio).to be_between(0.5, 1.5),
                           "Adapter: #{adapter_texts.size}, Reference: #{ref_texts.size} (ratio: #{ratio.round(2)})"
      end
    end
  end

  # ── Guide ────────────────────────────────────────────────────────

  describe "guide" do
    let(:pres_xml) { File.join(FIXTURES, "guide/document.presentation.xml") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Terms and definitions",
          "climate change",
        ])
      end
    end
  end

  # ── International Workshop Agreement ─────────────────────────────

  describe "international-workshop-agreement" do
    let(:pres_xml) { File.join(FIXTURES, "international-workshop-agreement/document.presentation.xml") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Terms and definitions",
          "standards professionals",
        ])
      end
    end
  end

  # ── Publicly Available Specification ─────────────────────────────

  describe "publicly-available-specification" do
    let(:pres_xml) { File.join(FIXTURES, "publicly-available-specification/document.presentation.xml") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Terms and definitions",
          "marine fuel quality",
        ])
      end
    end
  end

  # ── Technical Specification ──────────────────────────────────────

  describe "technical-specification" do
    let(:pres_xml) { File.join(FIXTURES, "technical-specification/document.presentation.xml") }

    it "generates a valid DOCX with key content" do
      generate_adapter_output(pres_xml) do |output_path, _adapter|
        expect(File.size(output_path)).to be > 1000
        texts = extract_paragraph_texts(output_path)
        expect_content_present(texts, [
          "Foreword",
          "Scope",
          "Terms and definitions",
          "Fire safety",
        ])
      end
    end
  end
end
