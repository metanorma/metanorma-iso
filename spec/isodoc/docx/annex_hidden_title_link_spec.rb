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
end
