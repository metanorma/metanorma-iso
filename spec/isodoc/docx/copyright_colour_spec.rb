# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../../support/copyright_docx_helper"

# Keep saved-DOCX regressions alongside the repository's other DOCX specs.
RSpec.describe IsoDoc::Iso::Docx::BoilerplateRenderer do # rubocop:disable RSpec/SpecFilePathFormat
  include CopyrightDocxHelper

  let(:xml) do
    minimal_iso_xml(<<~XML)
      <boilerplate>
        <copyright-statement>
          <clause>
            <title>Copyright notice</title>
            <p>All rights reserved.</p>
            <p>ISO copyright office</p>
          </clause>
        </copyright-statement>
        <legal-statement><clause><p>Legal notice.</p></clause></legal-statement>
        <feedback-statement><clause><p>Feedback notice.</p></clause></feedback-statement>
      </boilerplate>
      <sections/>
    XML
  end
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:parts) { copyright_docx_parts(xml, template) }
  let(:paragraphs) { copyright_paragraphs(parts.first) }

  { simple: "0000FF", dis: "0000FF" }.each do |template_name, colour|
    context "with the #{template_name} template" do
      let(:template) { template_name }

      it "applies the copyright style to every copyright page paragraph" do
        expected = ["zzCopyright", "zzCopyright",
                    template == :dis ? "zzCopyrightaddress" : "zzCopyright",
                    "zzCopyright", "zzCopyright"]
        expect(paragraphs.map { |p| p.at_xpath("w:pPr/w:pStyle/@w:val", ns)&.value })
          .to eq(expected)
      end

      it "keeps the template text colour in the saved style" do
        expect(parts.last.at_xpath("//w:style[@w:styleId='zzCopyright']/w:rPr/w:color/@w:val", ns)&.value).to eq(colour)
      end

      it "renders the statement unboxed and left-aligned like DOC" do
        style = parts.last.at_xpath("//w:style[@w:styleId='zzCopyright']", ns)
        expect(style.at_xpath("w:pPr/w:pBdr", ns)).to be_nil
        expect(style.at_xpath("w:pPr/w:jc/@w:val", ns)&.value).to eq("left")
      end

      it "inherits text colour without direct colour overrides" do
        expect(paragraphs.flat_map { |p| p.xpath(".//w:rPr/w:color", ns) }).to be_empty
      end

      it "takes copyright borders and alignment from the template" do
        expect(copyright_style_snapshot(parts.last))
          .to eq(copyright_style_snapshot(copyright_template_styles(template)))
      end

      it "inherits borders and alignment without paragraph overrides" do
        expect(paragraphs.flat_map { |p| p.xpath("w:pPr/w:jc | w:pPr/w:pBdr", ns) }).to be_empty
      end
    end
  end
end
