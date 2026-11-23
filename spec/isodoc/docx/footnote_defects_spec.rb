# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "nokogiri"

# Footnote hyperlinks in MHTML output, empty link targets, and nested footnotes.
RSpec.describe "footnote link and nesting defects" do
  let(:ns) do
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
      "rel" => "http://schemas.openxmlformats.org/package/2006/relationships" }
  end

  def source(body)
    minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title>#{body}</clause></sections>
    INNER
  end

  def docx_parts(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      build_adapter.convert(source(body), path)
      Zip::File.open(path) do |z|
        %w[word/footnotes.xml word/_rels/footnotes.xml.rels].to_h do |n|
          [n, z.find_entry(n) && Nokogiri::XML(z.read(n))]
        end
      end
    end
  end

  def mhtml_footnotes(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.doc")
      build_adapter.convert(source(body), path)
      raw = File.binread(path).gsub("\r\n", "\n")
      raw[/mso-element:footnote-list.*?<\/html>=0A/m].to_s.unpack1("M").force_encoding("UTF-8")
    end
  end

  def user_footnotes(parts)
    parts["word/footnotes.xml"].xpath("//w:footnote[not(@w:type)]", ns)
  end

  describe "MHTML output" do
    it "keeps a named link and its target in a footnote body" do
      html = mhtml_footnotes('<p>T<fn reference="1"><p>ex <link target="https://example.org/a">link</link></p></fn>.</p>')
      expect(html).to match(%r{<a href="https://example.org/a">.*link.*</a>}m)
    end

    it "keeps a mailto-only footnote" do
      html = mhtml_footnotes('<p>T<fn reference="1"><p><link target="mailto:a@b.org"/></p></fn>.</p>')
      expect(html).to include('href="mailto:a@b.org"')
    end

    it "keeps body and footnote links with distinct targets" do
      html = mhtml_footnotes('<p><link target="https://example.org/body"/> T<fn reference="1"><p><link target="https://example.org/fn"/></p></fn>.</p>')
      expect(html).to include('href="https://example.org/fn"')
    end
  end

  describe "empty link target" do
    it "keeps the link text" do
      parts = docx_parts('<p>T<fn reference="1"><p><link target="">empty</link> ok</p></fn>.</p>')
      expect(user_footnotes(parts).last.text).to include("empty")
    end

    it "writes no relationship without a Target and keeps the text" do
      parts = docx_parts('<p>T<fn reference="1"><p><link target="">empty</link> ok</p></fn>.</p>')
      rels = parts["word/_rels/footnotes.xml.rels"]
      targets = rels ? rels.xpath("//rel:Relationship", ns).map { |r| r["Target"] } : []
      expect(targets).to all(satisfy { |t| !t.to_s.empty? })
    end
  end

  describe "nested footnote" do
    let(:notes) do
      user_footnotes(docx_parts('<p>A<fn reference="1"><p>nested <fn reference="2"><p>inner</p></fn></p></fn> end</p>'))
    end

    it "keeps the inner footnote text in the outer body" do
      expect(notes.map { |n| n.text.gsub(/\s+/, " ").strip }).to eq(["nested inner"])
    end
  end
end
