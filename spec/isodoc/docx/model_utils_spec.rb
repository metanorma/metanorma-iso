# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::ModelUtils do
  # Create a test class that includes the module
  let(:utilizer) do
    Class.new do
      include IsoDoc::Iso::Docx::ModelUtils
    end.new
  end

  describe "#extract_texts" do
    it "returns text from model objects" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Title</fmt-title>
            <p>Plain text paragraph.</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para = root.preface.foreword.paragraphs.first
      texts = utilizer.extract_texts(para)
      expect(texts).to include("Plain text paragraph.")
    end
  end

  describe "#collect_text" do
    it "returns string unchanged" do
      expect(utilizer.collect_text("hello")).to eq("hello")
    end

    it "extracts text from model objects" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Title</fmt-title>
            <p>Plain text paragraph.</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para = root.preface.foreword.paragraphs.first
      expect(utilizer.collect_text(para)).to eq("Plain text paragraph.")
    end

    it "returns empty string for nil" do
      expect(utilizer.collect_text(nil)).to eq("")
    end
  end

  describe "#ordered?" do
    it "returns true for model objects with element_order" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>T</fmt-title>
            <p>c</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para = root.preface.foreword.paragraphs.first
      expect(utilizer.ordered?(para)).to be(true)
    end

    it "returns false for strings" do
      expect(utilizer.ordered?("text")).to be(false)
    end

    it "returns false for nil" do
      expect(utilizer.ordered?(nil)).to be(false)
    end
  end

  describe "#each_ordered_element" do
    it "yields text and element pairs in document order" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>T</fmt-title>
            <p>Hello <em>world</em> end</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para = root.preface.foreword.paragraphs.first

      items = []
      utilizer.each_ordered_element(para) { |type, obj| items << [type, obj] }

      expect(items.length).to eq(3)
      expect(items[0][0]).to eq(:text)
      expect(items[0][1]).to eq("Hello ")
      expect(items[1][0]).to eq(:element)
      expect(items[1][1]).to be_a(Metanorma::Document::Components::Inline::EmRawElement)
      expect(items[2][0]).to eq(:text)
      expect(items[2][1]).to eq(" end")
    end

    it "returns an enumerator when no block given" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>T</fmt-title>
            <p>text</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para = root.preface.foreword.paragraphs.first

      enum = utilizer.each_ordered_element(para)
      expect(enum).to be_a(Enumerator)
    end

    it "caches element mapping per model class" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>T</fmt-title>
            <p>first</p>
            <p>second</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      paras = root.preface.foreword.paragraphs
      expect(paras.size).to eq(2)

      cache = IsoDoc::Iso::Docx::ModelUtils::ELEMENT_MAPPING_CACHE
      cache.clear

      utilizer.each_ordered_element(paras[0]) { |_| }
      klass = paras[0].class
      expect(cache).to have_key(klass)

      cached_before = cache[klass]
      utilizer.each_ordered_element(paras[1]) { |_| }
      expect(cache[klass]).to equal(cached_before)
    end
  end

  describe "#parse_dimension" do
    it "converts pt to twips" do
      expect(utilizer.parse_dimension("10pt")).to eq(200)
    end

    it "converts px to EMU" do
      expect(utilizer.parse_dimension("100px")).to eq(952_500)
    end

    it "converts cm to EMU" do
      expect(utilizer.parse_dimension("1cm")).to eq(360_000)
    end

    it "converts in to EMU" do
      expect(utilizer.parse_dimension("1in")).to eq(914_400)
    end

    it "converts bare numbers" do
      expect(utilizer.parse_dimension("500")).to eq(500)
    end

    it "returns nil for nil" do
      expect(utilizer.parse_dimension(nil)).to be_nil
    end
  end

  describe "#parse_twips" do
    it "returns integer for bare numbers" do
      expect(utilizer.parse_twips("5000")).to eq(5000)
    end

    it "delegates to parse_dimension for CSS values" do
      expect(utilizer.parse_twips("1in")).to eq(914_400)
    end

    it "returns nil for nil" do
      expect(utilizer.parse_twips(nil)).to be_nil
    end
  end
end
