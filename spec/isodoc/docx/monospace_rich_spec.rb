# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# TtElement models only text and semx, so bold, italic, link, footnote and
# stem inside <tt> were dropped. They must survive, in order, as InlineCode.
RSpec.describe "rich content inside tt" do
  let(:ns) do
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
      "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      "rel" => "http://schemas.openxmlformats.org/package/2006/relationships" }
  end

  def convert(sections)
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">T</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>#{sections}</sections>
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |z|
        %w[word/document.xml word/footnotes.xml
           word/_rels/document.xml.rels].to_h do |n|
          [n, z.find_entry(n) && Nokogiri::XML(z.read(n))]
        end
      end
    end
  end

  def body(inner, title: "Scope")
    convert("<clause id='c1'><title>#{title}</title><p id='p1'>#{inner}</p></clause>")
  end

  def doc(parts)
    parts["word/document.xml"]
  end

  # [[text, rStyle], ...] for the runs of the paragraph with id p1's text.
  def runs_in(node)
    node.xpath(".//w:r", ns).filter_map do |r|
      text = r.xpath("./w:t", ns).map(&:text).join
      next if text.empty?

      [text, r.at_xpath("./w:rPr/w:rStyle/@w:val", ns)&.value]
    end
  end

  def code_para(parts)
    doc(parts).xpath("//w:p", ns).find { |p| p.xpath(".//w:t", ns).text.include?("pre") }
  end

  it "keeps plain tt as one InlineCode run" do
    runs = runs_in(code_para(body("pre <tt>a b</tt> post")))
    expect(runs).to eq([["pre ", nil], ["a b", "InlineCode"], [" post", nil]])
  end

  it "keeps strong, in order, in monospace" do
    runs = runs_in(code_para(body("pre <tt>a <strong>b</strong> c</tt> post")))
    inside = runs.select { |_, s| s&.start_with?("InlineCode") }
    expect(inside.map(&:first).join).to eq("a b c")
    expect(inside.size).to eq(3)
    expect(runs.map(&:first).join).to eq("pre a b c post")
  end

  it "keeps em as italic monospace" do
    para = code_para(body("pre <tt>a <em>b</em> c</tt>"))
    run = para.xpath(".//w:r", ns).find { |r| r.xpath("./w:t", ns).text == "b" }
    expect(run.at_xpath("./w:rPr/w:rStyle/@w:val", ns).value).to eq("InlineCode")
    expect(run.at_xpath("./w:rPr/w:i", ns)).not_to be_nil
  end

  { "keyword" => [], "smallcap" => ["w:smallCaps"],
    "underline" => ["w:u"], "strike" => ["w:strike"] }.each do |tag, properties|
    it "keeps #{tag} in order in monospace" do
      para = code_para(body("pre <tt>a<#{tag}>rich</#{tag}>b</tt> post"))
      runs = runs_in(para)
      expect(runs.map(&:first).join).to eq("pre arichb post")
      expect(runs[1...-1].map(&:last).uniq).to eq(["InlineCode"])
      run = para.xpath(".//w:r", ns).find { |r| r.xpath("./w:t", ns).text == "rich" }
      properties.each do |property|
        expect(run.at_xpath("./w:rPr/#{property}", ns)).not_to be_nil
      end
    end
  end

  it "keeps a line break between monospace text runs" do
    para = code_para(body("pre <tt>a<br/>b</tt> post"))
    expect(runs_in(para)).to eq([["pre ", nil], ["a", "InlineCode"],
                                 ["b", "InlineCode"], [" post", nil]])
    expect(para.xpath(".//w:r/w:t | .//w:r/w:br", ns).map(&:name))
      .to eq(%w[t t br t t])
  end

  it "keeps a link in order, resolvable" do
    parts = body('pre <tt>a <link target="https://example.org/x">site</link> c</tt>')
    para = code_para(parts)
    link = para.at_xpath(".//w:hyperlink", ns)
    expect(link.xpath(".//w:t", ns).text).to eq("site")
    rel = parts["word/_rels/document.xml.rels"]
      .at_xpath("//rel:Relationship[@Id='#{link['r:id']}']", ns)
    expect(rel["Target"]).to eq("https://example.org/x")
    expect(link.at_xpath(".//w:rStyle/@w:val", ns).value).to eq("InlineCode")
    expect(para.xpath(".//w:t", ns).text).to eq("pre a site c")
  end

  it "keeps a footnote once, with its body" do
    parts = body('pre <tt>a<fn reference="1"><p>note body</p></fn> c</tt> post')
    expect(doc(parts).xpath("//w:footnoteReference", ns).size).to eq(1)
    notes = parts["word/footnotes.xml"].xpath("//w:footnote[not(@w:type)]", ns)
    expect(notes.size).to eq(1)
    expect(notes.first.text).to include("note body")
    expect(code_para(parts).xpath(".//w:t", ns).text).to eq("pre a c post")
  end

  it "keeps a stem" do
    parts = body("pre <tt>a <stem type='AsciiMath'><asciimath>x</asciimath></stem> c</tt>")
    para = code_para(parts)
    expect(para.xpath(".//w:t | .//m:t", "w" => ns["w"], "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math").text)
      .to include("x")
  end

  it "keeps a semx xref beside rich content" do
    runs = runs_in(code_para(body("pre <tt>a <strong>b</strong> <semx element='xref' source='i'>" \
                                  "<fmt-xref target='c1'>[c]</fmt-xref></semx> z</tt>")))
    inside = runs.select { |_, s| s&.start_with?("InlineCode") }
    expect(inside.map(&:first).join).to eq("a b [c] z")
  end

  it "keeps rich tt in a heading" do
    parts = body("x", title: "Use <tt>a <strong>b</strong></tt>")
    head = doc(parts).xpath("//w:p", ns).find { |p| p.xpath(".//w:t", ns).text.include?("Use") }
    expect(runs_in(head).map(&:first).join).to start_with("Use a b")
  end

  it "keeps rich tt in a table cell" do
    parts = convert("<clause id='c1'><title>S</title><table id='t'><tbody><tr>" \
                    "<td>pre <tt>a <strong>b</strong></tt></td></tr></tbody></table></clause>")
    cell = doc(parts).at_xpath("//w:tc", ns)
    expect(runs_in(cell).map(&:first).join).to eq("pre a b")
  end
end
