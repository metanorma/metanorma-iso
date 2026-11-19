# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# An untitled inline-header sub-clause has no heading paragraph, but its
# number must still lead its first body paragraph, with a bookmark named
# after the clause id so cross-references resolve (as in the ISO HTML).
RSpec.describe IsoDoc::Iso::Docx::Adapter, "untitled clause number" do
  let(:adapter) { build_adapter }
  let(:inner) do
    <<~INNER
      <sections>
        <clause id="parent">
          <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum">5</semx></span><span class="fmt-caption-delim"><tab/></span>Parent Clause</fmt-title>
          <p>Parent intro.</p>
          <clause id="untitled" inline-header="true">
            <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">5</semx><span class="fmt-autonum-delim">.</span><semx element="autonum">1</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
            <p>Untitled sub-clause body text.</p>
            <p>Second paragraph.</p>
          </clause>
          <clause id="next" inline-header="true">
            <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">5</semx><span class="fmt-autonum-delim">.</span><semx element="autonum">2</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
            <p>Next body.</p>
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

  it "leads the first body paragraph with the number and a clause-id bookmark",
     :aggregate_failures do
    convert do |doc, ns|
      para = para_with(doc, ns, "Untitled sub-clause body text.")
      expect(para.xpath(".//w:t", ns).map(&:text).join).to start_with("5.1")
      expect(para.at_xpath("w:pPr/w:pStyle[starts-with(@w:val,'Heading')]", ns)).to be_nil

      bm = para.at_xpath("w:bookmarkStart[@w:name='untitled']", ns)
      expect(bm).not_to be_nil
      # The bookmark wraps the number run (non-empty range).
      expect(bm.next_element.xpath(".//w:t", ns).map(&:text).join).to eq("5.1")
      expect(para.at_xpath("w:bookmarkEnd[@w:id='#{bm['w:id']}']", ns)).not_to be_nil
      expect(bm.next_element.at_xpath("w:rPr/w:b", ns)).not_to be_nil
    end
  end

  it "adds no paragraph: only the first paragraph gets the number",
     :aggregate_failures do
    convert do |doc, ns|
      expect(para_with(doc, ns, "Second paragraph.").xpath(".//w:t", ns).map(&:text).join)
        .to eq("Second paragraph.")
      texts = doc.xpath("//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
      from = texts.index("Parent intro.") - 1
      expect(texts[from..]).to eq(
        ["Parent Clause", "Parent intro.", "5.1Untitled sub-clause body text.",
         "Second paragraph.", "5.2Next body."],
      )
      expect(doc.xpath("//w:bookmarkStart[@w:name='untitled' or @w:name='next']", ns).length).to eq(2)
      expect(para_with(doc, ns, "Next body.").xpath(".//w:t", ns).map(&:text).join)
        .to start_with("5.2")
    end
  end
end
