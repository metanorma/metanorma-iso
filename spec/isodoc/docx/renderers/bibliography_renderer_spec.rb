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
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
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
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
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
end
