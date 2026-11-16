# frozen_string_literal: true

require_relative "../spec_helper"
require "cgi"

RSpec.describe IsoDoc::Iso::Docx::Renderers::DefinitionListRenderer do
  let(:adapter) { build_adapter }

  describe "formula-zone dl rendering (KeyTitle + KeyText)" do
    it "renders dt as KeyTitle and dd as KeyText inside <formula>" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><mo>=</mo><mi>y</mi></math></stem>
              <dl>
                <dt>X</dt>
                <dd>The X coordinate</dd>
                <dt>Y</dt>
                <dd>The Y coordinate</dd>
              </dl>
            </formula>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| para_style_value(p) }

        expect(styles).to include("KeyTitle"),
          "expected at least one KeyTitle paragraph, got: #{styles.inspect}"
        expect(styles).to include("KeyText"),
          "expected at least one KeyText paragraph, got: #{styles.inspect}"
      end
    end
  end

  describe "general dl rendering (Definition style)" do
    it "renders both dt and dd as Definition outside formula" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <dl>
              <dt>Term1</dt>
              <dd>Definition for term1</dd>
            </dl>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| para_style_value(p) }

        expect(styles).to include("Definition"),
          "expected at least one Definition paragraph, got: #{styles.inspect}"
        expect(styles).not_to include("KeyTitle"),
          "KeyTitle should not appear outside formula zone, got: #{styles.inspect}"
      end
    end
  end

  # Definition-list terms that are plain text carrying XML-hostile
  # characters must survive into the DOCX output. The isodoc Word
  # (MHTML) path dropped such terms: WordFunction::Body#dt_parse
  # appended dterm.text via Nokogiri Builder#<<, which parses its
  # argument as markup, so a bare "&" or "<" made the insertion invalid
  # and the term cell came out empty (isodoc#898, fixed in isodoc#900
  # by appending as text instead of markup). The uniword path appends
  # text through the typed model (ParagraphBuilder#<<, escaped at
  # serialization), so the same terms must round-trip intact here.
  describe "definition-list term escaping (isodoc#898 consistency)" do
    XML_HOSTILE_TERMS = ["&", "&&", "<", "<<", ">>", "||"].freeze

    def hostile_dl_xml
      dts = XML_HOSTILE_TERMS.each_with_index.map do |term, i|
        "<dt>#{CGI.escapeHTML(term)}</dt><dd>definition #{i}</dd>"
      end.join

      minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Operators</title>
            <dl>#{dts}</dl>
          </clause>
        </sections>
      INNER
    end

    it "renders bare & and < term text in the DOCX paragraphs" do
      convert_and_extract(adapter, hostile_dl_xml) do |pkg|
        texts = pkg.document.body.paragraphs.map do |p|
          Array(p.runs).map { |r| run_text(r) }.join
        end

        XML_HOSTILE_TERMS.each do |term|
          expect(texts).to include(term),
            "term #{term.inspect} lost in DOCX output; paragraphs: " \
            "#{texts.compact.inspect}"
        end
      end
    end

    it "serializes the term text as escaped XML in document.xml" do
      Dir.mktmpdir("dt-escape-") do |dir|
        path = File.join(dir, "escaped.docx")
        adapter.convert(hostile_dl_xml, path)

        raw = Zip::File.open(path) do |zip|
          zip.find_entry("word/document.xml").get_input_stream.read
        end

        # A raw & or < in the stream would make the package unreadable:
        # strict-parse before any content assertions.
        doc = Nokogiri::XML(raw) { |c| c.strict }
        w = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        serialized = doc.xpath("//w:t", w).map(&:text)

        XML_HOSTILE_TERMS.each do |term|
          expect(serialized).to include(term),
            "term #{term.inspect} not present in serialized document.xml"
        end
        expect(raw).to include("&amp;"), "no escaped ampersand serialized"
        expect(raw).to include("&lt;"), "no escaped less-than serialized"
      end
    end
  end
end
