# frozen_string_literal: true

require_relative "spec_helper"

# Cross-renderer contract for titles shared between headings and the ToC.
RSpec.describe "DOCX localized contents and heading footnotes" do # rubocop:disable RSpec/DescribeClass
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:xml) do
    minimal_iso_xml(<<~INNER)
      <preface>
        <clause type="toc" id="toc"><fmt-title>Sommaire</fmt-title></clause>
      </preface>
      <sections>
        <clause id="scope">
          <title>Scope<fn reference="1" id="fn-source"><p>Heading note.</p></fn></title>
          <fmt-title><semx element="title">Scope<fn reference="1" id="fn-rendered"><p>Heading note.</p></fn></semx></fmt-title>
          <variant-title type="toc"><semx element="title">Scope<fn reference="1" id="fn-toc"><p>Heading note.</p></fn></semx></variant-title>
          <p>Scope body.</p>
        </clause>
        <clause id="ordinary"><fmt-title>Ordinary</fmt-title><p>Ordinary body.</p></clause>
      </sections>
    INNER
  end
  let(:parts) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        %w[document footnotes].to_h do |name|
          [name, Nokogiri::XML(zip.read("word/#{name}.xml"))]
        end
      end
    end
  end
  let(:document) { parts.fetch("document") }
  let(:entries) do
    document.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'TOC') and string-length(@w:val)=4]]", ns)
  end

  it "uses the presentation's localized contents title", :aggregate_failures do
    expect(document.xpath("//w:t", ns).map(&:text)).to include("Sommaire")
    expect(document.xpath("//w:t", ns).map(&:text)).not_to include("Contents")
  end

  it "renders each heading note only at its body heading", :aggregate_failures do
    expect(document.xpath("//w:footnoteReference", ns).size).to eq(1)
    expect(entries.flat_map { |p| p.xpath(".//w:footnoteReference", ns) }).to be_empty
    expect(document.xpath("//w:t", ns).map(&:text)).not_to include("Heading note.")
    expect(parts.fetch("footnotes").xpath("//w:t", ns).map(&:text).join).to eq(" Heading note.")
  end

  it "preserves ordinary heading, body, and contents text", :aggregate_failures do
    expect(entries.map { |p| p.xpath(".//w:t", ns).map(&:text).join }).to eq(["Scope1", "Ordinary1"])
    body_text = document.xpath("//w:p[w:pPr/w:pStyle[@w:val='BodyText']]/w:r/w:t", ns).map(&:text)
    expect(body_text).to eq(["Scope body.", "Ordinary body."])
  end

  context "with formatted annex headings" do
    let(:xml) do
      minimal_iso_xml(<<~INNER)
        <sections/>
        <annex id="a1" obligation="normative">
          <fmt-title><strong><bookmark id="title-anchor"/>Annex with <xref target="a1">ISO 1234:2000</xref> link and <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>a</mi><mo>+</mo><mi>b</mi></math><asciimath>a+b</asciimath></stem> tail</strong></fmt-title>
          <p>Annex body.</p>
        </annex>
      INNER
    end

    it "preserves the mixed sequence in both heading and contents", :aggregate_failures do
      paragraphs = document.xpath("//w:p[w:pPr/w:pStyle[@w:val='ANNEX' or @w:val='TOC1']]", ns)
      expect(paragraphs.size).to eq(2)
      expect(paragraphs.map { |p| p.xpath(".//*[local-name()='t']").map(&:text).join })
        .to eq(["Annex with ISO 1234:2000 link and a+b tail1", "Annex with ISO 1234:2000 link and a+b tail"])
      expect(paragraphs.map { |p| p.xpath(".//*[local-name()='oMath']").size }).to eq([1, 1])
    end

    it "keeps source bookmarks on the body heading", :aggregate_failures do
      expect(entries.flat_map { |p| p.xpath(".//w:bookmarkStart", ns) }).to be_empty
      expect(document.xpath("//w:p[w:pPr/w:pStyle[@w:val='ANNEX']]//w:bookmarkStart[@w:name='title-anchor']", ns).size).to eq(1)
    end
  end
end
