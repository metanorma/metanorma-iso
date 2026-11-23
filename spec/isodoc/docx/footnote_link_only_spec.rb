# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# A link-only footnote has no plain paragraph text, but its link is visible
# content and must still produce a reference and a resolvable footnote link.
RSpec.describe "link-only footnote content" do
  let(:ns) do
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
      "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      "rel" => "http://schemas.openxmlformats.org/package/2006/relationships" }
  end
  let(:footnote_body) { '<link target="https://e.org/s"/>' }
  let(:parts) do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1"><title>Scope</title>
          <p>Body text<fn reference="1"><p>#{footnote_body}</p></fn> remains.</p>
        </clause>
      </sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        %w[word/document.xml word/footnotes.xml word/_rels/footnotes.xml.rels].to_h do |name|
          [name, zip.find_entry(name) && Nokogiri::XML(zip.read(name))]
        end
      end
    end
  end

  it "preserves a footnote whose only content is a bare link" do
    document = parts["word/document.xml"]
    footnote = parts["word/footnotes.xml"].at_xpath("//w:footnote[not(@w:type)]", ns)
    link = footnote&.at_xpath(".//w:hyperlink", ns)
    rel_id = link&.at_xpath("@r:id", ns)&.value
    relationship = parts["word/_rels/footnotes.xml.rels"]
      &.at_xpath("//rel:Relationship[@Id='#{rel_id}']", ns)

    expect(
      references: document.xpath("//w:footnoteReference", ns).size,
      footnotes: parts["word/footnotes.xml"].xpath("//w:footnote[not(@w:type)]", ns).size,
      visible_url: footnote&.text&.include?("https://e.org/s"),
      link_target: relationship&.[]("Target"),
      target_mode: relationship&.[]("TargetMode"),
      body_text: document.text.include?("Body text") && document.text.include?("remains."),
    ).to eq(
      references: 1,
      footnotes: 1,
      visible_url: true,
      link_target: "https://e.org/s",
      target_mode: "External",
      body_text: true,
    )
  end

  context "with a named link" do
    let(:footnote_body) { '<link target="https://e.org/n">named site</link>' }

    it "preserves the link and its reference" do
      footnote = parts["word/footnotes.xml"].at_xpath("//w:footnote[not(@w:type)]", ns)

      expect(
        references: parts["word/document.xml"].xpath("//w:footnoteReference", ns).size,
        link_text: footnote&.xpath(".//w:hyperlink", ns)&.text,
      ).to eq(references: 1, link_text: "named site")
    end
  end

  context "with a bare link alongside text" do
    let(:footnote_body) { 'See <link target="https://e.org/t"/>' }

    it "preserves the link, text, and reference" do
      footnote = parts["word/footnotes.xml"].at_xpath("//w:footnote[not(@w:type)]", ns)

      expect(
        references: parts["word/document.xml"].xpath("//w:footnoteReference", ns).size,
        footnote_text: footnote&.text&.strip,
      ).to eq(references: 1, footnote_text: "See https://e.org/t")
    end
  end
end
