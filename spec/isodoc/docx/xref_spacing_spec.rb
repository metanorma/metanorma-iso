# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# P2-014: the card reported cross-references fusing with neighbouring text
# ("3.1husked rice", "Note13.5,Note1", ").B.3.2B.3.1"). Measured on the
# generated DOCX, those strings come from joining separate paragraphs
# (TermNum + Terms, adjacent table cells) in a text dump, not from xref runs.
# These examples pin the real behaviour: spacing around xrefs is preserved
# and term number / term name stay in separate paragraphs.
RSpec.describe "xref spacing in DOCX output" do
  let(:adapter) { build_adapter }
  let(:w) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  def convert(xml)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) { |doc, _| return doc }
    end
  end

  def para_text(para)
    para.xpath(".//w:t", w).map(&:text).join
  end

  def xref_body(inner)
    minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1" displayorder="1">
          <fmt-title>Scope</fmt-title>
          <p id="p1">#{inner}</p>
        </clause>
      </sections>
    INNER
  end

  it "keeps the spaces and punctuation around fmt-xref hyperlinks" do
    # Presentation XML always wraps fmt-xref in <semx element="xref">.
    link = ->(text) { %(<semx element="xref" source="x"><fmt-xref target="c1">#{text}</fmt-xref></semx>) }
    doc = convert(xref_body(
                    "See #{link['Clause 3']}, #{link['Note 1']} and (#{link['B.3.2']}) with #{link['B.3.1']}.",
                  ))
    para = doc.xpath("//w:p", w).find { |p| para_text(p).include?("See ") }

    expect(para_text(para)).to eq("See Clause 3, Note 1 and (B.3.2) with B.3.1.")
    expect(para.xpath(".//w:hyperlink", w).size).to eq(4)
  end

  describe "rice sample" do
    let(:doc) do
      @doc ||= convert(File.read("spec/examples/rice.presentation.xml"))
    end

    it "never places an alphanumeric hyperlink edge directly against alphanumeric text" do
      fused = []
      doc.xpath("//w:p", w).each do |p|
        kids = p.element_children.reject { |k| k.name == "pPr" }
        kids.each_with_index do |k, i|
          next unless k.name == "hyperlink"

          link = para_text(k)
          before = kids[i - 1] && i.positive? ? para_text(kids[i - 1]) : ""
          after = kids[i + 1] ? para_text(kids[i + 1]) : ""
          fused << [before[-12..] || before, link, after[0, 12]] if
            (before =~ /\p{Alnum}\z/ && link =~ /\A\p{Alnum}/) ||
              (after =~ /\A\p{Alnum}/ && link =~ /\p{Alnum}\z/)
        end
      end
      expect(fused).to eq([])
    end

    it "keeps term number and term name in separate paragraphs" do
      num = doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='TermNum']", w)
        .find { |p| para_text(p) == "3.1" }
      expect(num).not_to be_nil
      expect(para_text(num)).not_to include("paddy")
      expect(para_text(num.next_element)).to eq("paddy")
    end
  end
end
