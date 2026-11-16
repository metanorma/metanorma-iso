# frozen_string_literal: true

require_relative "../spec_helper"
require "zip"
require "nokogiri"

RSpec.describe IsoDoc::Iso::Docx::Renderers::BibliographyRenderer do
  let(:adapter) { build_adapter }

  it "renders informative bibliography items with BiblioEntry style" do
    xml = minimal_iso_xml(<<~INNER)
      <bibliography>
        <references id="bib">
          <title>Bibliography</title>
          <bibitem id="b1">
            <formattedref>Sample Reference, <em>Vol. 1</em>.</formattedref>
            <docidentifier>REF1</docidentifier>
          </bibitem>
        </references>
      </bibliography>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
      expect(styles).to include("BiblioEntry"),
        "informative bib item should use BiblioEntry, got: #{styles.inspect}"
    end
  end

  it "renders normative references items with RefNorm style" do
    xml = minimal_iso_xml(<<~INNER)
      <bibliography>
        <references id="nrm" normative="true">
          <title>Normative references</title>
          <bibitem id="b1">
            <formattedref>Normative Sample.</formattedref>
            <docidentifier>ISO 1234</docidentifier>
          </bibitem>
        </references>
      </bibliography>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
      expect(styles).to include("RefNorm"),
        "normative bib item should use RefNorm, got: #{styles.inspect}"
    end
  end

  it "embeds a bookmark with the bibitem id" do
    xml = minimal_iso_xml(<<~INNER)
      <bibliography>
        <references id="bib">
          <title>Bibliography</title>
          <bibitem id="myref1">
            <formattedref>Sample Reference.</formattedref>
            <docidentifier>REF1</docidentifier>
          </bibitem>
        </references>
      </bibliography>
    INNER

    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        doc = Nokogiri::XML(zip.find_entry("word/document.xml").get_input_stream.read)
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        names = doc.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
        expect(names).to include("myref1"),
          "bibitem id should be a bookmark name, got: #{names.inspect}"
      end
    end
  end

  it "renders bibitem notes as BiblioDescription paragraphs" do
    xml = minimal_iso_xml(<<~INNER)
      <bibliography>
        <references id="bib">
          <title>Bibliography</title>
          <bibitem id="b1">
            <formattedref>Sample Reference.</formattedref>
            <docidentifier>REF1</docidentifier>
            <note>Only available in English.</note>
          </bibitem>
        </references>
      </bibliography>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).to include("BiblioEntry"),
        "main entry should use BiblioEntry, got: #{styles.inspect}"
      expect(styles).to include("BiblioDescription"),
        "note should use BiblioDescription, got: #{styles.inspect}"
      entry_idx = styles.index("BiblioEntry")
      desc_idx = styles.index("BiblioDescription")
      expect(entry_idx).to be < desc_idx,
        "BiblioDescription should follow BiblioEntry"
    end
  end

  # metanorma-pdfa#120: a bibitem footnote (Unpublished-Status note lifted
  # into <fn> on the biblio-tag by the presentation layer) must render as a
  # real footnote — superscript label at the reference point, body once in
  # footnotes.xml — and the leftover <note> must not duplicate the footnote
  # body as a body paragraph.
  describe "bibitem footnote (Unpublished-Status)" do
    let(:fn_xml) do
      minimal_iso_xml(<<~INNER)
        <bibliography>
          <references id="bib">
            <title>Bibliography</title>
            <bibitem id="b1">
              <biblio-tag>[1]<tab/>ISO&#160;1234<fn id="_fn1" reference="_fn1"><p>Withdrawn.</p></fn>, </biblio-tag>
              <formattedref>Sample Reference.</formattedref>
              <docidentifier>ISO 1234</docidentifier>
              <note type="Unpublished-Status"><p>Withdrawn.</p></note>
            </bibitem>
          </references>
        </bibliography>
      INNER
    end

    it "places a footnoteReference (the label) at the reference point" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(fn_xml, path)
        extract_docx(path) do |doc, ns|
          refs = doc.xpath("//w:footnoteReference", ns)
          expect(refs).not_to be_empty,
            "bibitem footnote must produce a footnoteReference label"
          # The reference sits in the entry paragraph, not a note paragraph.
          para_text = refs.first
            .xpath("ancestor::w:p[1]//w:t", ns).map(&:text).join
          expect(para_text).to include("Sample Reference")
        end
      end
    end

    it "carries the footnote body once, in footnotes.xml" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(fn_xml, path)
        Zip::File.open(path) do |zip|
          fn = Nokogiri::XML(
            zip.find_entry("word/footnotes.xml").get_input_stream.read,
          )
          ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
          bodies = fn.xpath(
            "//w:footnote[not(@w:type)]//w:t", ns,
          ).select { |t| t.text.include?("Withdrawn") }
          expect(bodies.length).to eq(1),
            "footnote body must appear exactly once in footnotes.xml, " \
            "got #{bodies.length}"
        end
      end
    end

    it "does not duplicate the footnote body as a body paragraph" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(fn_xml, path)
        extract_docx(path) do |doc, ns|
          dupes = doc.xpath("//w:p", ns).select do |p|
            p.xpath(".//w:t", ns).map(&:text).join.strip == "Withdrawn."
          end
          expect(dupes).to be_empty,
            "Unpublished-Status note must not render as a body paragraph; " \
            "got #{dupes.length} duplicate paragraph(s)"
        end
      end
    end
  end
end
