# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"

RSpec.describe "DOCX preface page breaks", type: :feature do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:fixture) do
    File.expand_path("../../fixtures/iso/is/document-en.dis.presentation.xml", __dir__)
  end
  let(:boundaries) do
    Dir.mktmpdir("preface-breaks-") do |dir|
      output = File.join(dir, "output.docx")
      Metanorma::Iso::Processor.new.output(nil, fixture, output, :docx)
      Zip::File.open(output) { |zip| measure_boundaries(zip) }
    end
  end

  it "preserves the nine reference boundaries, including all three preface breaks" do
    expect(boundaries).to eq(
      explicit: %w[zzContents ForewordTitle IntroTitle ANNEX ANNEX ANNEX ANNEX ANNEX],
      bibliography: 1, bibliography_break: true, total: 9
    )
  end

  def measure_boundaries(zip)
    document = Nokogiri::XML(zip.read("word/document.xml"))
    styles = Nokogiri::XML(zip.read("word/styles.xml"))
    breaks = document.xpath("//w:br[@w:type='page']", ns)
    bibliography = document.xpath("//w:p[w:pPr/w:pStyle[@w:val='BiblioTitle']]", ns)
    # Bibliography uses its template style's pageBreakBefore, not w:br.
    page_break = styles.at_xpath("//w:style[@w:styleId='BiblioTitle']/w:pPr/w:pageBreakBefore", ns)
    {
      explicit: breaks.map { |br| following_style(br) },
      bibliography: bibliography.length,
      bibliography_break: !page_break.nil? && !%w[0 false off].include?(page_break["w:val"]),
      total: breaks.length + bibliography.length,
    }
  end

  def following_style(page_break)
    paragraph = page_break.ancestors.find { |node| node.name == "p" }
    following = paragraph.xpath("following-sibling::w:p", ns).find do |node|
      !node.xpath(".//w:t", ns).text.strip.empty?
    end
    following&.at_xpath("w:pPr/w:pStyle/@w:val", ns)&.value
  end
end
