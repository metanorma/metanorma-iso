# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "DOCX hyperlinks for concepts and bookmarks for paragraphs" do
  let(:xml) do
    minimal_iso_xml(<<~XML)
      <sections><clause id="c1"><title>Scope</title>
        <p id="p_plain">Plain paragraph.</p>
        <p id="p_concept">The <fmt-concept><semx element="concept" source="k1"><em>paddy</em>
          <semx element="xref" source="x1">(<fmt-xref target="term-paddy">3.1</fmt-xref>)</semx></semx></fmt-concept> grain.</p>
      </clause>
      <terms id="terms"><title>Terms</title>
        <term id="term-paddy" anchor="term-paddy"><preferred><expression><name>paddy</name></expression></preferred>
          <definition><verbal-definition><p>rice</p></verbal-definition></definition></term>
      </terms></sections>
    XML
  end

  let(:document) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end

  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:bookmark_names) { document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value) }

  it "renders the xref inside a fmt-concept as an internal hyperlink" do
    anchors = document.xpath("//w:hyperlink/@w:anchor", ns).map(&:value)
    expect(anchors).to include("term-paddy")
  end

  it "keeps the xref display text inside the concept" do
    expect(document.xpath("//w:body", ns).text).to include("paddy (3.1)")
  end

  it "bookmarks paragraphs carrying an id" do
    expect(bookmark_names).to include("p_plain", "p_concept")
  end

  it "keeps bookmark names unique" do
    expect(bookmark_names).to eq(bookmark_names.uniq)
  end

  it "closes every bookmark" do
    starts = document.xpath("//w:bookmarkStart/@w:id", ns).map(&:value)
    ends = document.xpath("//w:bookmarkEnd/@w:id", ns).map(&:value)
    expect(starts.sort).to eq(ends.sort)
  end
end
