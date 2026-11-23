# frozen_string_literal: true

require_relative "spec_helper"

# Package-level behavior spans the ToC builder and annex renderer.
# rubocop:disable-next RSpec/DescribeClass
RSpec.describe "DOCX annex ToC rebuild sources" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:xml) do
    minimal_iso_xml(<<~XML)
      <sections/>
      <annex id="annexA" obligation="#{obligation}">
        <fmt-title><span class="fmt-caption-label">Annex <semx element="autonum">A</semx></span><br/><span class="fmt-obligation">(#{obligation})</span><span class="fmt-caption-delim"><br/><br/></span><semx element="title">Test methods</semx></fmt-title>
        <variant-title type="toc"><span class="fmt-caption-label">Annex <semx element="autonum">A</semx></span><tab/><semx element="title">Test methods</semx></variant-title>
        <p>Annex body.</p>
      </annex>
    XML
  end
  let(:document) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "annex.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end

  %w[normative informative].each do |value|
    context "with a #{value} annex" do
      let(:obligation) { value }

      it "caches the qualifier on one line", :aggregate_failures do
        entry = document.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='TOC1']", ns)
        expect(entry.xpath(".//w:t", ns).map(&:text).join.split.join(" "))
          .to eq("Annex A (#{obligation}) Test methods1")
        expect(entry.xpath(".//w:br", ns)).to be_empty
      end

      it "selects exactly one complete ANNEX heading on rebuild", :aggregate_failures do
        headings = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", ns)
        expect(headings.size).to eq(1)
        expect(headings.first.xpath(".//w:t", ns).map(&:text).join)
          .to eq("(#{obligation})Test methods")
        expect(headings.first.xpath(".//w:br", ns).size).to eq(3)
      end

      it "selects ANNEX without preserving soft breaks in the rebuilt ToC", :aggregate_failures do
        instruction = document.xpath("//w:instrText", ns).map(&:text).find { |t| t.include?(" TOC ") }
        expect(instruction).to include("ANNEX,1")
        expect(instruction).not_to include('\\x')
      end

      it "omits the duplicate variant paragraph" do
        expect(document.xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)).to be_empty
      end
    end
  end
end
