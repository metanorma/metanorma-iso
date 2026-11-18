# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"

RSpec.describe "DOCX DIS table of contents", type: :feature do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:fixture) do
    File.expand_path("../../fixtures/iso/is/document-en.dis.presentation.xml", __dir__)
  end
  let(:document) do
    Dir.mktmpdir("toc-entries-") do |dir|
      output = File.join(dir, "output.docx")
      Metanorma::Iso::Processor.new.output(nil, fixture, output, :docx)
      Zip::File.open(output) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end

  let(:entries) do
    document.xpath(
      "//w:p[w:pPr/w:pStyle[@w:val='TOC1' or @w:val='TOC2' or @w:val='TOC3']]", ns
    )
  end

  it "writes TOC1/TOC2/TOC3 entries with a tab and PAGEREF to each heading bookmark",
     :aggregate_failures do
    expect_toc_levels
    expect_no_untitled_clauses
    entries.each { |entry| expect_heading_pageref(entry) }
    expect_bibliography_heading
  end

  def expect_bibliography_heading
    entry = entries.find do |para|
      para.xpath("w:r[w:tab]/preceding-sibling::w:r/w:t", ns).text.strip == "Bibliography"
    end
    field = entry&.at_xpath("w:r/w:instrText[contains(., 'PAGEREF')]", ns)
    target = field&.text.to_s.split[1]
    heading = document.at_xpath(
      "//w:p[w:pPr/w:pStyle[@w:val='BiblioTitle']][w:bookmarkStart[@w:name=$name]]",
      ns, name: target.to_s
    )
    expect(heading&.xpath(".//w:t", ns)&.text.to_s.strip).to eq("Bibliography")
  end

  def expect_no_untitled_clauses
    labels = entries.map { |entry| entry.xpath("w:r[w:tab]/preceding-sibling::w:r/w:t", ns).text.strip }
    expect(labels).not_to include("4.2.1", "4.2.2")
  end

  def expect_toc_levels
    styles = entries.map { |entry| entry.at_xpath("w:pPr/w:pStyle/@w:val", ns).value }
    expect(styles.uniq).to contain_exactly("TOC1", "TOC2", "TOC3")
  end

  def expect_heading_pageref(entry)
    label = entry.xpath(".//w:t", ns).text
    expect(entry.xpath("w:r/w:tab", ns).size).to eq(1), label
    fields = entry.xpath("w:r/w:instrText[contains(., 'PAGEREF')]", ns)
    expect(fields.size).to eq(1), label
    return unless fields.size == 1

    field = fields.first
    target = field.text[/\bPAGEREF\s+(\S+)\s+\\h\b/, 1]
    expect(target).not_to be_nil, label
    expect(field.parent.xpath("preceding-sibling::w:r/w:tab", ns).size).to eq(1), label
    expect_field_structure(field.parent)
    bookmark = document.at_xpath("//w:bookmarkStart[@w:name=$name]", ns, name: target.to_s)
    expect(bookmark).not_to be_nil, "#{label}: missing heading bookmark #{target}"
    return unless bookmark

    heading = bookmark.at_xpath("ancestor::w:p", ns)
    expect(heading&.xpath(".//w:t", ns)&.text.to_s.strip).not_to be_empty, label
  end

  def expect_field_structure(run)
    expect(run.previous_element.at_xpath("w:fldChar/@w:fldCharType", ns)&.value).to eq("begin")
    following = run.xpath("following-sibling::w:r", ns)
    expect(following[0].at_xpath("w:fldChar/@w:fldCharType", ns)&.value).to eq("separate")
    expect(following[1].at_xpath("w:t", ns)&.text).to eq("1")
    expect(following[2].at_xpath("w:fldChar/@w:fldCharType", ns)&.value).to eq("end")
  end
end
