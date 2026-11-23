# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# A link inside a footnote lives in word/footnotes.xml, so its r:id must
# resolve in word/_rels/footnotes.xml.rels, not in the document's rels.
RSpec.describe "links inside footnotes" do
  let(:w) { "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  let(:ns) do
    { "w" => w, "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      "rel" => "http://schemas.openxmlformats.org/package/2006/relationships" }
  end

  def convert(body)
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title>#{body}</clause></sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |z|
        %w[word/document.xml word/footnotes.xml word/_rels/document.xml.rels
           word/_rels/footnotes.xml.rels].to_h do |n|
          [n, z.find_entry(n) && Nokogiri::XML(z.read(n))]
        end
      end
    end
  end

  def fn_rels(parts)
    parts["word/_rels/footnotes.xml.rels"].xpath("//rel:Relationship", ns)
      .to_h { |r| [r["Id"], r] }
  end

  def fn_body(parts)
    parts["word/footnotes.xml"].xpath("//w:footnote[not(@w:type)]", ns).last
  end

  def para(fn_xml)
    "<p>Text<fn reference=\"1\"><p>#{fn_xml}</p></fn> end.</p>"
  end

  def link_ids(parts)
    parts["word/footnotes.xml"].xpath("//w:hyperlink/@r:id", ns).map(&:value)
  end

  it "resolves a bare URL and keeps the text in order" do
    parts = convert(para('Visit <link target="https://example.org/a"/> now.'))
    id = link_ids(parts).first
    expect(fn_rels(parts)[id]["Target"]).to eq("https://example.org/a")
    expect(fn_rels(parts)[id]["TargetMode"]).to eq("External")
    expect(fn_body(parts).text).to match(/Visit\s*https:\/\/example\.org\/a\s*now\./)
  end

  it "resolves a named link" do
    parts = convert(para('See <link target="https://example.org/b">the site</link>.'))
    id = link_ids(parts).first
    expect(fn_rels(parts)[id]["Target"]).to eq("https://example.org/b")
    expect(fn_body(parts).xpath(".//w:hyperlink", ns).text).to eq("the site")
  end

  it "resolves two links to distinct ids in order" do
    parts = convert(para('<link target="https://example.org/a"/> and <link target="https://example.org/b"/>'))
    ids = link_ids(parts)
    expect(ids.uniq.size).to eq(2)
    expect(ids.map { |i| fn_rels(parts)[i]["Target"] })
      .to eq(%w[https://example.org/a https://example.org/b])
    expect(fn_rels(parts).keys.size).to eq(fn_rels(parts).keys.uniq.size)
  end

  it "resolves a link inside bold" do
    parts = convert(para('<strong>bold <link target="https://example.org/c"/></strong>'))
    expect(link_ids(parts).size).to eq(1)
    expect(fn_rels(parts)[link_ids(parts).first]["Target"]).to eq("https://example.org/c")
  end

  it "keeps body hyperlinks on the document rels" do
    parts = convert('<p>Go <link target="https://example.org/body"/>.' \
                    '<fn reference="1"><p>x <link target="https://example.org/fn"/></p></fn></p>')
    body_id = parts["word/document.xml"].at_xpath("//w:hyperlink/@r:id", ns).value
    doc_rels = parts["word/_rels/document.xml.rels"].xpath("//rel:Relationship", ns)
    expect(doc_rels.find { |r| r["Id"] == body_id }["Target"]).to eq("https://example.org/body")
    expect(fn_rels(parts).values.map { |r| r["Target"] }).to eq(["https://example.org/fn"])
  end
end
