# frozen_string_literal: true

require_relative "spec_helper"

# Annex headings supply the rebuilt ToC without a duplicate paragraph.
RSpec.describe "DOCX annex ToC source with an inline link" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:document) do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 1:2016</docidentifier>
        <ext><doctype>international-standard</doctype></ext>
      </bibdata>
      <sections/>
      <annex id="a1" obligation="normative">
        <fmt-title>Annex <link target="https://example.com">linked</link> text</fmt-title>
        <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex <link target="https://example.com">linked</link> text</semx></variant-title>
        <p>Body.</p>
      </annex>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
    end
  end

  it "emits no duplicate variant paragraph or paragraph mark", :aggregate_failures do
    expect(document.xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)).to be_empty
    heading = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", ns)
    expect(heading.size).to eq(1)
    expect(heading.first.xpath(".//w:t", ns).map(&:text).join).to eq("Annex  text")
  end

  context "when the annex has an empty title" do
    let(:untitled) do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1:2016</docidentifier>
          <ext><doctype>international-standard</doctype></ext>
        </bibdata>
        <sections/>
        <annex id="a1" obligation="normative">
          <fmt-title/>
          <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span>Gelatin</variant-title>
          <p>Body.</p>
        </annex>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "out.docx")
        build_adapter.convert(xml, path)
        Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
      end
    end

    it "uses one ANNEX heading as the rebuild source without a duplicate paragraph", :aggregate_failures do
      headings = untitled.xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", ns)
      expect(headings.size).to eq(1)
      expect(headings.first.text).to include("Gelatin")
      entry = untitled.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='TOC1']", ns)
      expect(entry.text).to include("Gelatin")
    end

    it "keeps the annex id bookmark" do
      expect(untitled.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)).to include("a1")
    end
  end

  # A unit stem stays in the heading without printing a duplicate title.
  context "when the annex title carries a unit stem" do
    let(:stem) do
      '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
        '<mrow><mn>80</mn><mo rspace="thickmathspace">&#x2062;</mo>' \
        '<mrow xref="U_km"><mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow>' \
        '</mrow></math><asciimath>80 "unitsml(km)"</asciimath></stem>'
    end
    let(:with_stem) do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1:2016</docidentifier>
          <ext><doctype>international-standard</doctype></ext>
        </bibdata>
        <sections/>
        <annex id="a1" obligation="normative">
          <title>Alt #{stem}</title>
          <fmt-title><semx element="title">Alt #{stem}</semx></fmt-title>
          <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Alt #{stem}</semx></variant-title>
          <p>Body.</p>
        </annex>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "out.docx")
        build_adapter.convert(xml, path)
        Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
      end
    end
    let(:math_ns) { ns.merge("m" => "http://schemas.openxmlformats.org/officeDocument/2006/math") }

    it "emits no duplicate paragraph for the equation" do
      expect(with_stem.xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", math_ns)).to be_empty
    end

    it "still renders the equation in the heading" do
      heading = with_stem.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", math_ns)
      expect(heading.xpath(".//m:oMath", math_ns).length).to eq(1)
    end
  end
end
