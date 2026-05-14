# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "zip"
require "nokogiri"

RSpec.describe "DOCX integration", type: :integration do
  let(:adapter) { build_adapter }

  def generate_docx(xml_body)
    xml = minimal_iso_xml(xml_body)
    dir = Dir.mktmpdir
    output_path = File.join(dir, "output.docx")
    adapter.convert(xml, output_path)
    output_path
  end

  def extract_docx_xml(path, entry_name)
    Zip::File.open(path) do |zip|
      entry = zip.find_entry(entry_name)
      return nil unless entry

      Nokogiri::XML(entry.get_input_stream.read)
    end
  end

  # ── Template round-trip ──────────────────────────────────────────

  describe "ISO template round-trip" do
    it "template loads and re-saves successfully" do
      template_path = IsoDoc::Iso.default_docx_template
      expect(File.exist?(template_path)).to be(true)

      dir = Dir.mktmpdir
      output_path = File.join(dir, "template-rt.docx")
      doc = Uniword::Builder::DocumentBuilder.from_file(template_path)
      doc.save(output_path)
      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0
    end
  end

  # ── DOCX structure ──────────────────────────────────────────────

  describe "generated DOCX structure" do
    it "contains word/document.xml" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test content.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/document.xml")).not_to be_nil
      end
    end

    it "contains [Content_Types].xml" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        expect(zip.find_entry("[Content_Types].xml")).not_to be_nil
      end
    end

    it "document.xml contains w:body with paragraphs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test paragraph content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      body = doc.at_xpath("//w:body", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
      expect(body).not_to be_nil

      paragraphs = body.xpath("w:p", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
      expect(paragraphs.length).to be >= 2 # title + paragraph
    end

    it "headings have correct styleId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      heading = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']]", ns)
      expect(heading).not_to be_nil
    end

    it "bookmark start/end pairs are balanced" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="scope">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      starts = doc.xpath("//w:bookmarkStart", ns)
      ends = doc.xpath("//w:bookmarkEnd", ns)
      expect(starts.length).to eq(ends.length)
    end

    it "section properties have A4 page size" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      pg_sz = doc.at_xpath("//w:pgSz", ns)
      expect(pg_sz).not_to be_nil
      expect(pg_sz["w:w"]).to eq("11906")
      expect(pg_sz["w:h"]).to eq("16838")
    end

    it "contains headers and footers" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        header_entries = zip.entries.select { |e| e.name.match?(/header\d+\.xml/) }
        footer_entries = zip.entries.select { |e| e.name.match?(/footer\d+\.xml/) }
        expect(header_entries.length).to be >= 1
        expect(footer_entries.length).to be >= 1
      end
    end

    it "bold runs use w:b" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p><strong>Bold text</strong></p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      bold_runs = doc.xpath("//w:rPr/w:b", ns)
      expect(bold_runs.length).to be >= 1
    end

    it "italic runs use w:i" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p><em>Italic text</em></p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      italic_runs = doc.xpath("//w:rPr/w:i", ns)
      expect(italic_runs.length).to be >= 1
    end
  end

  # ── Element-specific DOCX structure ────────────────────────────────

  describe "table structure" do
    it "contains w:tbl with rows and cells" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1</fmt-name>
              <thead>
                <tr><th>H1</th><th>H2</th></tr>
              </thead>
              <tbody>
                <tr><td>C1</td><td>C2</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      tbl = doc.at_xpath("//w:tbl", ns)
      expect(tbl).not_to be_nil
      rows = tbl.xpath("w:tr", ns)
      expect(rows.length).to eq(2)
    end
  end

  describe "list numbering" do
    it "unordered list paragraphs have numId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <ul>
              <li><p>Item 1</p></li>
              <li><p>Item 2</p></li>
            </ul>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      num_ids = doc.xpath("//w:numPr/w:numId/@w:val", ns).map(&:to_s)
      expect(num_ids.length).to be >= 2
      # dash_list numId is 10
      expect(num_ids.uniq).to include("10")
    end
  end

  # ── Full document conversion ────────────────────────────────────

  describe "full document conversion" do
    it "converts a document with all major elements" do
      xml_body = <<~INNER
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>This is the foreword with <em>italic</em> and <strong>bold</strong> text.</p>
          </foreword>
          <introduction id="intro">
            <fmt-title>Introduction</fmt-title>
            <p>Introduction paragraph.</p>
          </introduction>
        </preface>
        <sections>
          <clause id="scope">
            <fmt-title>Scope</fmt-title>
            <p>This International Standard defines requirements.</p>
            <clause id="scope-general">
              <fmt-title>General</fmt-title>
              <p>General scope text.</p>
            </clause>
          </clause>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>quality</name></expression></preferred>
              <definition><verbal-definition><p>Degree of excellence.</p></verbal-definition></definition>
              <termnote id="tn1"><p>Quality is subjective.</p></termnote>
            </term>
          </terms>
        </sections>
        <annex id="annex-a">
          <fmt-title>Annex A (informative)</fmt-title>
          <p>Additional information.</p>
          <table id="t1">
            <fmt-name>Table A.1</fmt-name>
            <thead>
              <tr><th>Column 1</th><th>Column 2</th></tr>
            </thead>
            <tbody>
              <tr><td>Value 1</td><td>Value 2</td></tr>
            </tbody>
          </table>
        </annex>
        <bibliography id="bib">
          <fmt-title>Bibliography</fmt-title>
          <p>[1] ISO 9001, Quality management systems.</p>
        </bibliography>
      INNER

      path = generate_docx(xml_body)
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0

      doc = extract_docx_xml(path, "word/document.xml")
      expect(doc).not_to be_nil
    end
  end

  # ── convert_model ───────────────────────────────────────────────

  describe "convert_model" do
    it "produces valid DOCX from a pre-parsed model" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Model conversion test.</p>
          </foreword>
        </preface>
      INNER

      model = parse_iso_document(xml)
      dir = Dir.mktmpdir
      output_path = File.join(dir, "model.docx")
      adapter.convert_model(model, output_path)

      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0

      doc = extract_docx_xml(output_path, "word/document.xml")
      expect(doc).not_to be_nil
    end
  end

  # ── Real-world XML from mn-samples-iso ─────────────────────────

  describe "real-world document conversion" do
    let(:guide_xml_path) do
      File.expand_path("../../../../mn-samples-iso/site/documents/guide/document.xml",
                        __dir__)
    end

    before do
      skip "mn-samples-iso guide XML not available" unless File.exist?(guide_xml_path)
    end

    it "converts mn-samples-iso guide document to valid DOCX" do
      xml = File.read(guide_xml_path, encoding: "utf-8")
      dir = Dir.mktmpdir
      output_path = File.join(dir, "guide.docx")
      adapter.convert(xml, output_path)

      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 20_000

      doc = extract_docx_xml(output_path, "word/document.xml")
      expect(doc).not_to be_nil

      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }

      paragraphs = doc.xpath("//w:p", ns)
      expect(paragraphs.length).to be >= 40

      headings = doc.xpath("//w:p[w:pPr/w:pStyle[contains(@w:val, 'Heading')]]", ns)
      expect(headings.length).to be >= 5
    end
  end
end
