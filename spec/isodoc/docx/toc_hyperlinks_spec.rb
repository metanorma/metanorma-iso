# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"

# Every ToC entry links its full text to the heading bookmark. Annex
# headings must not be followed by an extra variant-title paragraph.
RSpec.describe "DOCX ToC hyperlinks and annex variant-title-toc",
               type: :feature do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:fixture) { File.expand_path("../../examples/rice.presentation.xml", __dir__) }
  let(:document) do
    Dir.mktmpdir("toc-links-") do |dir|
      output = File.join(dir, "output.docx")
      Metanorma::Iso::Processor.new.output(nil, fixture, output, :docx)
      Zip::File.open(output) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end
  let(:entries) do
    document.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'TOC') and string-length(@w:val)=4]]", ns)
  end
  let(:bookmark_names) do
    document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
  end

  it "wraps each entry in a hyperlink whose anchor, PAGEREF and a heading bookmark agree",
     :aggregate_failures do
    expect(entries.size).to be > 20
    entries.each do |entry|
      link = entry.at_xpath("./w:hyperlink", ns)
      expect(link).not_to be_nil
      anchor = link["w:anchor"]
      expect(anchor).to match(/\A_Toc[0-9a-f]+\z/)
      expect(link.at_xpath(".//w:instrText", ns).text).to include("PAGEREF #{anchor} ")
      expect(bookmark_names.count(anchor)).to eq(1)
      expect(link.xpath(".//w:t", ns).map(&:text).join).not_to be_empty
      expect(entry.xpath(".//w:t[not(ancestor::w:hyperlink)]", ns)).to be_empty
      expect(link.at_xpath(".//w:tab", ns)).not_to be_nil
    end
  end

  it "keeps every bookmark name unique" do
    expect(bookmark_names).to eq(bookmark_names.uniq)
  end

  it "omits the duplicate annex variant-title paragraphs" do
    expect(document.xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)).to be_empty
  end
end
