# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::TermsSectionRenderer do
  let(:adapter) { build_adapter }

  context "with the DIS terms introduction" do
    let(:intro) do
      fixture = File.expand_path(
        "../../../fixtures/iso/is/document-en.dis.presentation.xml", __dir__
      )
      source = Nokogiri::XML(File.read(fixture))
      terms = source.at_xpath("//*[local-name()='sections']/*[local-name()='terms']")
      terms.element_children.take_while { |node| node.name != "term" }
    end
    let(:urls) { %w[https://www.iso.org/obp https://www.electropedia.org] }
    let(:rendered) do
      xml = minimal_iso_xml("<sections><terms>#{intro.map(&:to_xml).join}</terms></sections>")
      Dir.mktmpdir do |dir|
        path = File.join(dir, "terms.docx")
        adapter.convert(xml, path)
        Zip::File.open(path) do |zip|
          doc = Nokogiri::XML(zip.read("word/document.xml"))
          rels = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
          paragraphs = doc.xpath("//w:body/w:p").map do |paragraph|
            paragraph.xpath(".//w:t").map(&:text).join
          end
          # External links only: TOC entries are internal w:anchor links.
          links = doc.xpath("//w:body//w:hyperlink[@r:id]").map do |link|
            [link.xpath(".//w:t").map(&:text).join,
             rels.at_xpath("//*[@Id='#{link['r:id']}']/@Target").value]
          end
          { paragraphs: paragraphs, links: links }
        end
      end
    end

    it "keeps the document's introductory wording exactly once" do
      paragraphs = rendered[:paragraphs].grep(/\A(?:For the purposes|ISO and IEC maintain)/)
      expect(paragraphs).to eq(intro.select { |node| node.name == "p" }.map(&:text))
    end

    it "renders each HTTPS address exactly once" do
      paragraphs = rendered[:paragraphs].grep(/Online browsing platform|Electropedia/)
      expect(paragraphs).to eq(["ISO Online browsing platform: available at #{urls[0]}",
                                "IEC Electropedia: available at #{urls[1]}"])
    end

    it "preserves the HTTPS hyperlink targets" do
      expect(rendered[:links]).to eq(urls.map { |url| [url, url] })
    end
  end

  it "renders terms section title with Heading1" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms and definitions</title>
          <term id="t1"><preferred><expression><name>Term one</name></expression></preferred></term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p) == "Heading1"
      end
      expect(heading_paras.length).to be >= 1,
        "terms section title should use Heading1"
    end
  end
end
