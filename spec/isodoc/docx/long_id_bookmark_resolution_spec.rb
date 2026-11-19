# frozen_string_literal: true

require_relative "spec_helper"

# An element id over Word's 40-character bookmark limit gets a
# deterministic short bookmark name, and every xref to it resolves to
# that emitted bookmark (#1728).
RSpec.describe "DOCX bookmarks and xrefs for ids over the bookmark limit" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:clause_id) { "clause_with_a_very_long_identifier_over_forty_chars" }
  let(:note_id) { "note_with_a_very_long_identifier_over_forty_chars_x" }
  let(:list_id) { "list_with_a_very_long_identifier_over_forty_chars_y" }
  let(:twin_id) { "clause_with_a_very_long_identifier_over_forty_chars_2" }
  let(:document) do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 1:2016</docidentifier>
        <ext><doctype>international-standard</doctype></ext>
      </bibdata>
      <sections>
        <clause id="#{clause_id}"><title>Long</title>
          <p>See <xref target="#{clause_id}">clause</xref>, <xref target="#{note_id}">note</xref>,
          <xref target="#{list_id}">list</xref>, <xref target="#{twin_id}">twin</xref>.</p>
          <note id="#{note_id}"><p>A note.</p></note>
          <ul id="#{list_id}"><li><p>Item.</p></li></ul>
        </clause>
        <clause id="#{twin_id}"><title>Twin</title><p>Body.</p></clause>
      </sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
    end
  end
  let(:bookmark_names) { document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value) }
  let(:anchors) { document.xpath("//w:hyperlink/@w:anchor", ns).map(&:value) }

  it "emits no bookmark name twice, none over 40 characters", :aggregate_failures do
    expect(bookmark_names).to eq(bookmark_names.uniq)
    expect(bookmark_names.map(&:length).max).to be <= 40
  end

  it "resolves xrefs to a long heading, note, list and near-identical id", :aggregate_failures do
    [clause_id, note_id, list_id, twin_id].each do |id|
      anchor = mapped_name(id)
      expect(anchors).to include(anchor)
      expect(bookmark_names).to include(anchor)
    end
    expect(mapped_name(clause_id)).not_to eq(mapped_name(twin_id))
  end

  it "leaves every internal hyperlink anchor resolvable" do
    dangling = anchors.reject { |a| bookmark_names.include?(a) }
    expect(dangling).to eq([])
  end

  context "when two headings repeat one long id" do
    let(:document) do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1:2016</docidentifier>
          <ext><doctype>international-standard</doctype></ext>
        </bibdata>
        <sections>
          <clause id="#{clause_id}"><title>One</title><p>Body.</p></clause>
          <clause id="#{clause_id}"><title>Two</title><p>Body.</p></clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "out.docx")
        build_adapter.convert(xml, path)
        Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
      end
    end

    it "emits the id bookmark and its _Toc twin once each" do
      expect(bookmark_names).to eq(bookmark_names.uniq)
    end
  end

  context "when a formula, bibliography entry or split paragraph has a long id" do
    let(:formula_id) { "formula_with_a_very_long_identifier_over_forty_chars_f" }
    let(:bib_id) { "bibitem_with_a_very_long_identifier_over_forty_chars" }
    let(:split_id) { "split_para_with_a_very_long_identifier_over_forty_chars" }
    let(:document) do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1:2016</docidentifier>
          <ext><doctype>international-standard</doctype></ext>
        </bibdata>
        <sections>
          <clause id="CL"><title>One</title>
            <p>See <xref target="#{formula_id}">formula</xref>, <eref bibitemid="#{bib_id}">bib</eref>
            and <xref target="#{split_id}">split</xref>.</p>
            <formula id="#{formula_id}"><stem type="AsciiMath">x=1</stem></formula>
            <p id="#{split_id}">Lead text.<note><p>A note.</p></note> Tail text.</p>
          </clause>
        </sections>
        <bibliography>
          <references id="_normative_references" normative="true">
            <bibitem id="#{bib_id}" type="standard">
              <title>T</title><docidentifier>ISO 2</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "out.docx")
        build_adapter.convert(xml, path)
        Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
      end
    end

    it "bookmarks each under its mapped name, so the links resolve", :aggregate_failures do
      [formula_id, bib_id, split_id].each do |id|
        expect(anchors).to include(mapped_name(id))
        expect(bookmark_names).to include(mapped_name(id))
      end
      expect(anchors.reject { |a| bookmark_names.include?(a) }).to eq([])
      expect(bookmark_names.map(&:length).max).to be <= 40
    end
  end

  def mapped_name(id)
    IsoDoc::Iso::Docx::Context.new.bookmark_name(id)
  end
end
