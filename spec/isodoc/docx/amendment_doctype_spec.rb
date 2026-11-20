# frozen_string_literal: true

require_relative "spec_helper"

# metanorma-iso#1728 / card P3-006. The classic converter ran amendments
# with @suppressheadingnumbers (clause titles unnumbered, no TOC) and
# re-enabled numbering inside <amend><newcontent>. The Word clause
# numbers come from the style's numPr, so "unnumbered" is a direct
# numId 0 on the heading paragraph.
RSpec.describe IsoDoc::Iso::Docx::AmendmentDoctype do
  let(:adapter) { build_adapter }

  def amendment_xml(doctype)
    minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 17301-1:2016/Amd 1:2017</docidentifier>
        <ext><doctype language="">#{doctype}</doctype><doctype language="en">#{doctype.capitalize}</doctype></ext>
      </bibdata>
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body.</p>
          <amend id="a1" change="add">
            <description><p>Add the following clause.</p></description>
            <newcontent>
              <clause id="n1"><title>Added clause</title><p>New text.</p></clause>
            </newcontent>
          </amend>
        </clause>
        <clause id="c2"><title>Following</title><p>More.</p></clause>
      </sections>
    INNER
  end

  def paragraphs_titled(pkg, title)
    pkg.document.body.paragraphs.select do |p|
      Array(p.runs).map { |r| run_text(r) }.join.strip == title
    end
  end

  def num_id(para)
    para.properties.numbering_properties&.num_id&.value
  end

  def with_docx(xml, &)
    convert_and_extract(adapter, xml, &)
  end

  %w[amendment technical-corrigendum].each do |doctype|
    context "with doctype #{doctype}" do
      it "omits the table of contents", :aggregate_failures do
        with_docx(amendment_xml(doctype)) do |pkg|
          styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
          expect(styles.grep(/\ATOC/)).to be_empty
          expect(styles).not_to include("zzContents")
        end
      end

      it "suppresses heading numbers on clause titles outside amend newcontent", :aggregate_failures do
        with_docx(amendment_xml(doctype)) do |pkg|
          ids = %w[Scope Following].map { |t| num_id(paragraphs_titled(pkg, t).first) }
          expect(ids).to eq([0, 0])
        end
      end

      it "keeps heading numbers inside amend newcontent", :aggregate_failures do
        with_docx(amendment_xml(doctype)) do |pkg|
          para = paragraphs_titled(pkg, "Added clause").first
          expect(para).not_to be_nil
          expect(num_id(para)).to be_nil
        end
      end
    end
  end

  context "with an ordinary doctype" do
    it "keeps the TOC and numbered clause headings", :aggregate_failures do
      with_docx(amendment_xml("international-standard")) do |pkg|
        styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
        expect(styles).to include("zzContents")
        expect(num_id(paragraphs_titled(pkg, "Scope").first)).to be_nil
      end
    end
  end
end
