# frozen_string_literal: true

require_relative "spec_helper"

# Cross-renderer output contract, including the cached ToC and body headings.
RSpec.describe "DOCX section heading hierarchy" do # rubocop:disable RSpec/DescribeClass
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:document) do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="scope"><title>Scope</title><p>Scope body.</p></clause>
        <terms id="terms"><title>Terms and definitions</title>
          <terms id="general"><title>General terms</title>
            <clause id="specific"><title>Specific terms</title><p>Term context.</p></clause>
            <term id="term-one"><preferred><expression><name>Term one</name></expression></preferred></term>
          </terms>
        </terms>
        <clause id="ordinary"><title>Ordinary clause</title>
          <clause id="ordinary-sub"><title>Ordinary subclause</title><p>Body.</p></clause>
        </clause>
        <references id="normative" normative="true"><title>Normative references</title>
          <bibitem id="required"><biblio-tag>[1]</biblio-tag><title>Required reference metadata</title><formattedref>Required reference.</formattedref></bibitem>
        </references>
      </sections>
      <bibliography>
        <clause id="bibliography"><title>Bibliography</title>
          <references id="untitled"><bibitem id="ref-one"><biblio-tag>[2]</biblio-tag><title>First reference metadata</title><formattedref>First reference.</formattedref></bibitem></references>
          <references id="sub-bib"><title>Further reading</title>
            <bibitem id="ref-two"><biblio-tag>[3]</biblio-tag><title>Second reference metadata</title><formattedref>Second reference.</formattedref></bibitem>
          </references>
        </clause>
      </bibliography>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "hierarchy.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end
  let(:headings) do
    document.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'Heading')]]", ns).to_h do |para|
      [para.xpath(".//w:t", ns).map(&:text).join,
       para.at_xpath("w:pPr/w:pStyle/@w:val", ns).value]
    end
  end
  let(:entries) do
    document.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'TOC')]]", ns).map do |para|
      [para.xpath(".//w:t", ns).map(&:text).join,
       para.at_xpath("w:pPr/w:pStyle/@w:val", ns).value,
       para.at_xpath("w:hyperlink/@w:anchor", ns)&.value]
    end
  end

  it "nests terms headings and their clause children", :aggregate_failures do
    expect(headings).to include("Terms and definitions" => "Heading1",
                                "General terms" => "Heading2", "Specific terms" => "Heading3")
  end

  it "nests titled references beneath a bibliography clause" do
    expect(headings).to include("Bibliography" => "Heading1", "Further reading" => "Heading2")
  end

  it "preserves ordinary and top-level normative headings", :aggregate_failures do
    expect(headings).to include("Scope" => "Heading1", "Ordinary clause" => "Heading1",
                                "Ordinary subclause" => "Heading2", "Normative references" => "Heading1")
    texts = document.xpath("//w:p[w:pPr/w:pStyle[@w:val='BiblioEntry' or @w:val='RefNorm']]//w:t", ns).map(&:text)
    expect(texts).to include("First reference.", "Second reference.", "Required reference.")
  end

  it "lists nested terms and bibliography headings at their heading levels" do
    expect(entries.map { |text, style, _| [text, style] }).to include(
      ["Terms and definitions1", "TOC1"], ["General terms1", "TOC2"], ["Specific terms1", "TOC3"],
      ["Bibliography1", "TOC1"], ["Further reading1", "TOC2"]
    )
  end

  it "targets each listed heading bookmark exactly once and excludes entries", :aggregate_failures do
    bookmarks = document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
    expect(entries.map(&:last)).to all(satisfy { |anchor| bookmarks.count(anchor) == 1 })
    expect(entries.map(&:first).join).not_to match(/Term one|reference metadata/)
  end
end
