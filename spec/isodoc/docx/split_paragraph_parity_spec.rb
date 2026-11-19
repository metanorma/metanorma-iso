# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# A <p> holding a block child (a note) is rendered by the split path. It
# must behave like a simple paragraph for the id bookmark (P1-008) and the
# queued untitled-clause number (BUG 020), and an untitled clause whose
# first child is not a paragraph gets its number in its own leading
# paragraph.
RSpec.describe IsoDoc::Iso::Docx::Adapter, "split paragraph parity" do
  let(:adapter) { build_adapter }

  def title(sub)
    <<~T
      <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">5</semx><span class="fmt-autonum-delim">.</span><semx element="autonum">#{sub}</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
    T
  end

  def convert(inner)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(minimal_iso_xml("<sections><clause id=\"parent\"><fmt-title depth=\"1\"><span class=\"fmt-caption-label\"><semx element=\"autonum\">5</semx></span><span class=\"fmt-caption-delim\"><tab/></span>Parent</fmt-title>#{inner}</clause></sections>"), path)
      extract_docx(path) { |doc, ns| yield doc, ns }
    end
  end

  def text_of(para, ns)
    para.xpath(".//w:t", ns).map(&:text).join
  end

  def para_with(doc, ns, text)
    doc.xpath("//w:p", ns).find { |p| text_of(p, ns).include?(text) }
  end

  it "bookmarks an id-bearing split paragraph on its first output paragraph",
     :aggregate_failures do
    convert(<<~X) do |doc, ns|
      <p id="splitp">Before note.<note id="n1"><p id="np1">Note text.</p></note> After note.</p>
    X
      first = para_with(doc, ns, "Before note.")
      bm = first.at_xpath("w:bookmarkStart[@w:name='splitp']", ns)
      expect(bm).not_to be_nil
      expect(first.at_xpath("w:bookmarkEnd[@w:id='#{bm['w:id']}']", ns)).not_to be_nil
      expect(doc.xpath("//w:bookmarkStart[@w:name='splitp']", ns).length).to eq(1)
      expect(para_with(doc, ns, "After note.").at_xpath("w:bookmarkStart[@w:name='splitp']", ns)).to be_nil
    end
  end

  it "puts the untitled-clause number and bookmark on the first split paragraph only",
     :aggregate_failures do
    convert(<<~X) do |doc, ns|
      <clause id="untitled" inline-header="true">#{title(1)}
        <p id="sp2">Before note.<note id="n1"><p id="np1">Note text.</p></note> After note.</p>
      </clause>
    X
      first = para_with(doc, ns, "Before note.")
      expect(text_of(first, ns)).to start_with("5.1")
      bm = first.at_xpath("w:bookmarkStart[@w:name='untitled']", ns)
      expect(bm).not_to be_nil
      expect(bm.next_element.xpath(".//w:t", ns).map(&:text).join).to eq("5.1")
      expect(first.at_xpath("w:bookmarkStart[@w:name='sp2']", ns)).not_to be_nil
      expect(text_of(para_with(doc, ns, "Note text."), ns)).to eq("Note text.")
      expect(text_of(para_with(doc, ns, "After note."), ns)).to eq(" After note.").or eq("After note.")
      expect(doc.xpath("//w:bookmarkStart[@w:name='untitled']", ns).length).to eq(1)
    end
  end

  it "gives the number its own leading paragraph when the first child is not a paragraph",
     :aggregate_failures do
    convert(<<~X) do |doc, ns|
      <clause id="untitled" inline-header="true">#{title(1)}
        <ul id="l1"><li><p>Item text.</p></li></ul>
        <p>Later paragraph.</p>
      </clause>
    X
      lead = doc.xpath("//w:p", ns).find { |p| text_of(p, ns) == "5.1" }
      expect(lead).not_to be_nil
      expect(lead.at_xpath("w:bookmarkStart[@w:name='untitled']", ns)).not_to be_nil
      expect(text_of(para_with(doc, ns, "Item text."), ns)).to eq("Item text.")
      expect(text_of(para_with(doc, ns, "Later paragraph."), ns)).to eq("Later paragraph.")
    end
  end

  it "leads with a number paragraph, not the note, when the <p> opens with a note",
     :aggregate_failures do
    convert(<<~X) do |doc, ns|
      <clause id="untitled" inline-header="true">#{title(1)}
        <p id="sp3"><note id="n1"><p id="np1">Note text.</p></note>After note.</p>
        <p>Later paragraph.</p>
      </clause>
    X
      texts = doc.xpath("//w:p", ns).map { |p| text_of(p, ns) }
      from = texts.index { |t| t.include?("Note text.") || t == "5.1" }
      expect(texts[from, 4].map { |t| t.sub(/\ANOTE\s*/, "") }).to eq(
        ["5.1", "Note text.", "After note.", "Later paragraph."],
      )
      lead = doc.xpath("//w:p", ns).find { |p| text_of(p, ns) == "5.1" }
      expect(lead.at_xpath("w:bookmarkStart[@w:name='untitled']", ns)).not_to be_nil
      expect(text_of(para_with(doc, ns, "Note text."), ns)).not_to include("5.1")
      expect(doc.xpath("//w:bookmarkStart[@w:name='untitled']", ns).length).to eq(1)
      expect(para_with(doc, ns, "After note.").at_xpath("w:bookmarkStart[@w:name='sp3']", ns)).not_to be_nil
    end
  end
end
