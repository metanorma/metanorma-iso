# frozen_string_literal: true

require_relative "spec_helper"

# ToC entry hardening (#1728): inline links in a clause title must not
# reorder the entry text, and a clause id over Word's 40-character
# bookmark limit must still have the _Toc bookmark its ToC entry targets.
RSpec.describe "DOCX ToC entries with inline links and long ids" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:long_id) { "clause_with_a_very_long_identifier_over_forty_chars" }
  let(:document) do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 1:2016</docidentifier>
        <ext><doctype>international-standard</doctype></ext>
      </bibdata>
      <sections>
        <clause id="c1"><title>Scope with <link target="https://example.com">a link</link> here</title><p>Body.</p></clause>
        <clause id="#{long_id}"><title>Long id clause</title><p>Body.</p></clause>
      </sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
    end
  end
  let(:entries) do
    document.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val,'TOC') and string-length(@w:val)=4]]", ns)
  end
  let(:bookmark_names) { document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value) }

  it "keeps the entry text in title order around an inline link", :aggregate_failures do
    entry = entries.find { |p| p.text.include?("Scope with") }
    expect(entry.xpath(".//w:t", ns).map(&:text).join).to eq("Scope with a link here1")
    anchors = entry.xpath("./w:hyperlink/@w:anchor", ns).map(&:value)
    expect(anchors.uniq.size).to eq(1)
    expect(anchors.size).to be >= 2
  end

  it "bookmarks the _Toc twin of an id Word cannot bookmark", :aggregate_failures do
    entry = entries.find { |p| p.text.include?("Long id clause") }
    anchor = entry.at_xpath("./w:hyperlink", ns)["w:anchor"]
    expect(anchor).to match(/\A_Toc[0-9a-f]+\z/)
    expect(bookmark_names.count(anchor)).to eq(1)
    expect(bookmark_names).not_to include(long_id)
    expect(bookmark_names).to eq(bookmark_names.uniq)
  end
end
