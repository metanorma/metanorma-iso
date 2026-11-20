# frozen_string_literal: true

require_relative "spec_helper"

# #1728: every ToC hyperlink and PAGEREF must target a bookmark the
# document actually emits, and a bookmark name is emitted at most once.
RSpec.describe "DOCX bookmark twins (ToC targets and inline bookmarks)",
               type: :feature do
  def ns
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  end

  def bibdata
    '<bibdata><docidentifier primary="true">ISO 1:2016</docidentifier>' \
      "<ext><doctype>international-standard</doctype></ext></bibdata>"
  end
  let(:untitled_annex_with_toc_text) do
    <<~BODY
      <sections/>
      <annex id="a1" obligation="normative">
        <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span>Gelatin</variant-title>
        <p>Body.</p>
      </annex>
    BODY
  end
  let(:untitled_annex_without_toc_text) do
    <<~BODY
      <sections/>
      <annex id="a2" obligation="normative">
        <p>Body.</p>
      </annex>
    BODY
  end
  let(:reused_clause_id) do
    <<~BODY
      <sections>
        <clause id="dup1"><title>One</title>
          <p>Text <bookmark id="dup1"/> more.</p>
        </clause>
      </sections>
    BODY
  end

  def inline_before_clause
    <<~BODY
      <sections>
        <clause id="c0"><title>Zero</title>
          <p>Intro <bookmark id="target"/> text.</p>
        </clause>
        <clause id="target"><title>Target heading</title>
          <p>Body.</p>
        </clause>
      </sections>
    BODY
  end

  def number_only_annex
    <<~BODY
      <sections/>
      <annex id="a7" obligation="normative">
        <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a7">A</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
        <p>Body.</p>
      </annex>
    BODY
  end

  def inline_before_number_only_annex
    <<~BODY
      <sections>
        <clause id="c0"><title>Zero</title>
          <p>Intro <bookmark id="a7"/> text.</p>
        </clause>
      </sections>
      <annex id="a7" obligation="normative">
        <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a7">A</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
        <p>Body.</p>
      </annex>
    BODY
  end

  def empty_title_annex
    <<~BODY
      <sections/>
      <annex id="a8" obligation="normative">
        <fmt-title/>
        <p>Body.</p>
      </annex>
    BODY
  end

  def document_for(body)
    xml = minimal_iso_xml("#{bibdata}\n#{body}")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end

  def bookmark_names(doc)
    doc.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
  end

  def toc_entries(doc)
    doc.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'TOC') and string-length(@w:val)=4]]", ns)
  end

  def toc_link_anchors(doc)
    toc_entries(doc).map { |entry| entry.at_xpath("./w:hyperlink/@w:anchor", ns)&.value }
  end

  # Text of the paragraph that holds the bookmark +name+.
  def bookmark_host_text(doc, name)
    host = doc.at_xpath("//w:p[.//w:bookmarkStart[@w:name='#{name}']]", ns)
    host && host.xpath(".//w:t", ns).map(&:text).join
  end

  def pageref_targets(doc)
    doc.xpath("//w:instrText", ns).map(&:text).grep(/PAGEREF /).map { |t| t[/PAGEREF (\S+)/, 1] }
  end

  context "with an annex that has no title but a toc variant-title" do
    let(:doc) { document_for(untitled_annex_with_toc_text) }

    let(:twin) { IsoDoc::Iso::Docx::Context.toc_bookmark_name("a1") }

    it "emits the annex id bookmark and its _Toc twin" do
      expect(bookmark_names(doc)).to include("a1", twin)
    end

    it "links its ToC entry and PAGEREF to the _Toc twin" do
      expect([toc_link_anchors(doc), pageref_targets(doc)]).to eq([[twin], [twin]])
    end
  end

  context "with an annex that has neither a title nor a toc variant-title" do
    it "lists no ToC entry" do
      expect(toc_entries(document_for(untitled_annex_without_toc_text))).to be_empty
    end
  end

  context "with an inline bookmark that reuses a clause id" do
    it "emits every bookmark name at most once" do
      expect(bookmark_names(document_for(reused_clause_id)).tally.values.max).to eq(1)
    end
  end

  context "with an inline bookmark that claims a clause id before its heading" do
    let(:doc) { document_for(inline_before_clause) }

    it "keeps the heading's _Toc twin, so every ToC link and PAGEREF resolves" do
      targets = toc_link_anchors(doc).compact + pageref_targets(doc)
      expect([targets.empty?, targets - bookmark_names(doc)]).to eq([false, []])
    end
  end

  context "with an annex whose title holds only its number" do
    let(:doc) { document_for(number_only_annex) }

    it "lists the annex, linked to the _Toc twin on its number" do
      twin = IsoDoc::Iso::Docx::Context.toc_bookmark_name("a7")
      expect([toc_link_anchors(doc), bookmark_host_text(doc, twin)]).to eq([[twin], "ABody."])
    end
  end

  context "with an inline bookmark that claims a number-only annex's id first" do
    let(:doc) { document_for(inline_before_number_only_annex) }

    it "links the annex's ToC entry to the annex, not to the inline bookmark" do
      anchor = toc_link_anchors(doc).last
      expect(bookmark_host_text(doc, anchor)).to eq("ABody.")
    end
  end

  context "with an annex whose title element is empty" do
    it "lists no blank ToC entry" do
      expect(toc_entries(document_for(empty_title_annex))).to be_empty
    end
  end
end
