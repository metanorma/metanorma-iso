# frozen_string_literal: true

require_relative "spec_helper"

# The hidden variant-title-toc paragraph after an annex heading must hide
# every run, including runs inside an inline link (a w:hyperlink child).
RSpec.describe "DOCX annex hidden ToC variant title with an inline link" do
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

  it "vanishes every run of the hidden paragraph, linked ones included", :aggregate_failures do
    hidden = document.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)
    expect(hidden).not_to be_nil
    expect(hidden.at_xpath(".//w:hyperlink//w:r", ns)).not_to be_nil
    visible = hidden.xpath(".//w:r[not(w:rPr/w:vanish)]", ns)
    expect(visible.map(&:text)).to eq([])
  end

  it "keeps the linked run between the text around it" do
    hidden = document.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)
    order = hidden.xpath("./w:r | ./w:hyperlink", ns).map(&:text)
    expect(order.join).to include("Annex linked text")
  end

  context "when the annex has no title" do
    let(:untitled) do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1:2016</docidentifier>
          <ext><doctype>international-standard</doctype></ext>
        </bibdata>
        <sections/>
        <annex id="a1" obligation="normative">
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

    it "keeps the hidden ToC paragraph" do
      hidden = untitled.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", ns)
      expect(hidden&.text).to include("Gelatin")
    end

    it "keeps the annex id bookmark" do
      expect(untitled.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)).to include("a1")
    end
  end

  # A unit stem in an annex title renders as OMML (#1728). The hidden
  # variant-title-toc paragraph must not show it: only runs can carry
  # w:vanish, so an equation there would print the title's unit twice.
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

    it "keeps the equation out of the hidden paragraph", :aggregate_failures do
      hidden = with_stem.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='variant-title-toc']", math_ns)
      expect(hidden).not_to be_nil
      expect(hidden.xpath(".//m:oMath", math_ns)).to be_empty
      expect(hidden.xpath(".//w:r[not(w:rPr/w:vanish)]", math_ns)).to be_empty
    end

    it "still renders the equation in the heading" do
      heading = with_stem.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", math_ns)
      expect(heading.xpath(".//m:oMath", math_ns).length).to eq(1)
    end
  end
end
