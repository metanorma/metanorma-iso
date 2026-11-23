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

  def simple_references_xml
    minimal_iso_xml(<<~INNER)
      <bibliography>
        <references normative="true">
          <bibitem id="normative">
            <formattedref>Required reference.</formattedref>
          </bibitem>
        </references>
        <references>
          <bibitem id="informative">
            <formattedref>Further reading.</formattedref>
          </bibitem>
        </references>
      </bibliography>
    INNER
  end

  def simple_reference_styles
    convert_and_extract(build_adapter(template: :simple), simple_references_xml) do |pkg|
      pkg.document.body.paragraphs.to_h do |para|
        [para.runs.map { |run| run_text(run) }.join, para_style_value(para)]
      end
    end
  end

  it "uses ListParagraph only for the bibliography entry in Simple output" do
    expect(simple_reference_styles).to include(
      "Further reading." => "ListParagraph",
      "Required reference." => satisfy { |style| style != "ListParagraph" },
    )
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

  def normative_footnote_xml
    entries = (1..2).map do |index|
      <<~ENTRY
        <bibitem id="b#{index}">
          <biblio-tag>ISO 123#{index}:2009<fn reference="1" target="withdrawn"><p>Withdrawn.</p><fmt-fn-label><span class="fmt-caption-label"><sup><semx element="autonum">1</semx><span class="fmt-label-delim">)</span></sup></span></fmt-fn-label></fn>
        , </biblio-tag>
          <formattedref>Sample reference.</formattedref>
        </bibitem>
      ENTRY
    end
    minimal_iso_xml(<<~INNER)
      <bibliography>
        <references normative="true">#{entries.join}</references>
      </bibliography>
    INNER
  end

  def normative_footnote_runs
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(normative_footnote_xml, path)
      extract_docx(path) do |doc, ns|
        refs = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='RefNorm']]/w:r[w:footnoteReference]", ns)
        refs.map { |ref| footnote_run_details(ref, ns) }
      end
    end
  end

  def footnote_run_details(ref, namespaces)
    suffix, separator = ref.xpath("following-sibling::w:r", namespaces).first(2)
    {
      identifier: ref.xpath("preceding-sibling::w:r/w:t", namespaces).map(&:text).join,
      footnote_id: ref.xpath("w:footnoteReference/@w:id", namespaces).text,
      anchor_style: ref.xpath("w:rPr/w:rStyle/@w:val", namespaces).text,
      suffix: suffix.xpath("w:t", namespaces).text,
      suffix_style: suffix.xpath("w:rPr/w:rStyle/@w:val", namespaces).text,
      suffix_align: suffix.xpath("w:rPr/w:vertAlign/@w:val", namespaces).text,
      separator: separator.xpath("w:t", namespaces).text,
    }
  end

  def expected_footnote_run(identifier, footnote_id)
    { identifier: identifier, footnote_id: footnote_id, anchor_style: "FootnoteReference",
      suffix: ")", suffix_style: "FootnoteReference", suffix_align: "superscript", separator: " , " }
  end

  it "keeps the footnote marker and separator after the year in normative references", :aggregate_failures do
    runs = normative_footnote_runs
    footnote_id = runs.first&.fetch(:footnote_id)
    expect(footnote_id).to match(/\A\d+\z/)
    expect(runs).to eq([expected_footnote_run("ISO 1231:2009", footnote_id),
                        expected_footnote_run("ISO 1232:2009", footnote_id)])
  end

  # P1-010 pin: the real IS fixture, not synthetic XML. The semantic normref
  # style maps to the template's RefNorm style (data/iso-dis/style_mapping.yml).
  def is_fixture_normref_entries
    Dir.mktmpdir do |dir|
      path = File.join(dir, "is.docx")
      adapter.convert(File.read("spec/fixtures/iso/is/document-en.presentation.xml"), path)
      extract_docx(path) do |doc, ns|
        styles = Zip::File.open(path) { |zip| zip.read("word/styles.xml") }
        entries = doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='RefNorm']", ns).map do |para|
          para.xpath("w:r", ns).map do |run|
            run.at_xpath("w:footnoteReference", ns) ? "[fn]" : run.xpath("w:t", ns).text
          end.join
        end
        [entries, styles.include?('w:styleId="RefNorm"')]
      end
    end
  end

  it "keeps IS fixture normative footnote markers on the flagged entries only", :aggregate_failures do
    entries, style_defined = is_fixture_normref_entries
    flagged, plain = entries.partition { |entry| entry.include?("[fn]") }
    expect([style_defined, entries.size]).to eq([true, 7])
    expect(flagged).to match([/\AISO.712\[fn\]\) , Cereals and cereal/,
                              /\AISO.16634:\u2014\[fn\]\) , Cereals, pulses/])
    expect(plain).to all(match(/\AISO.\d[\d:-]*, [[:alpha:]]/))
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
