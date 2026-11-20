# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "zip"

# A clause with no heading paragraph and no number (unnumbered and
# untitled, or with no title at all) used to drop its id bookmark, leaving
# xrefs to it without a target. The id bookmark now leads the first body
# paragraph as an empty range, as the number does for a numbered untitled
# clause. A clause whose first child is not a paragraph gets an empty
# anchor paragraph to carry it.
RSpec.describe IsoDoc::Iso::Docx::Adapter, "unnumbered clause bookmark" do
  let(:adapter) { build_adapter }
  let(:inner) do
    <<~INNER
      <sections>
        <clause id="parent">
          <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum">5</semx></span><span class="fmt-caption-delim"><tab/></span>Parent</fmt-title>
          <clause id="empty-title" inline-header="true" unnumbered="true">
            <fmt-title depth="2"></fmt-title>
            <p>Empty title body.</p>
          </clause>
          <clause id="no-title" unnumbered="true">
            <p>No title body.</p>
          </clause>
          <clause id="no-children" inline-header="true" unnumbered="true">
            <fmt-title depth="2"></fmt-title>
          </clause>
          <clause id="note-first" unnumbered="true">
            <note id="n1"><p>A note.</p></note>
          </clause>
        </clause>
      </sections>
    INNER
  end

  def convert
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(minimal_iso_xml(inner), path)
      extract_docx(path) { |doc, ns| yield doc, ns }
    end
  end

  def para_with(doc, ns, text)
    doc.xpath("//w:p", ns).find { |p| p.xpath(".//w:t", ns).map(&:text).join.include?(text) }
  end

  def bookmark(doc, ns, name)
    doc.xpath("//w:bookmarkStart[@w:name='#{name}']", ns)
  end

  it "bookmarks each clause exactly once", :aggregate_failures do
    convert do |doc, ns|
      %w[empty-title no-title no-children note-first].each do |name|
        expect(bookmark(doc, ns, name).length).to eq(1), name
      end
    end
  end

  it "puts the bookmark on the first body paragraph as an empty range",
     :aggregate_failures do
    convert do |doc, ns|
      %w[empty-title no-title].zip(["Empty title body.", "No title body."]).each do |name, text|
        para = para_with(doc, ns, text)
        bm = para.at_xpath("w:bookmarkStart[@w:name='#{name}']", ns)
        expect(bm).not_to be_nil
        expect(bm.next_element.name).to eq("bookmarkEnd")
        expect(bm.next_element["w:id"]).to eq(bm["w:id"])
        expect(para.xpath(".//w:t", ns).map(&:text).join).to eq(text)
      end
    end
  end

  it "gives a clause with no body paragraph an empty anchor paragraph",
     :aggregate_failures do
    convert do |doc, ns|
      %w[no-children note-first].each do |name|
        para = bookmark(doc, ns, name).first.parent
        expect(para.xpath("w:r", ns)).to be_empty, name
      end
    end
  end
end
