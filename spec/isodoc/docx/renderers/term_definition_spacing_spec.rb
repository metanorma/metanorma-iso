# frozen_string_literal: true

require_relative "../spec_helper"

# The DOC chain sets a Definition paragraph 12pt below the designations
# (only the first one) and leaves the template's Definition gap after it:
# 12pt in DIS, 6pt in Simple.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  def definition_xml(body)
    minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title><term id="t"><fmt-name>3.1</fmt-name>
        <fmt-preferred><p><semx element="preferred">widget</semx></p></fmt-preferred>
        <fmt-definition><semx element="definition" source="d">#{body}</semx></fmt-definition>
      </term></terms></sections>
    XML
  end

  def definition_spacing(template, body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter(template: template).convert(definition_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='Definition']", ns).map do |p|
          spacing = p.at_xpath("w:pPr/w:spacing", ns)
          [p.xpath(".//w:t", ns).map(&:text).join,
           spacing&.[]("w:before"), spacing&.[]("w:after")]
        end
      end
    end
  end

  {
    dis: "240",
    simple: "120",
  }.each do |template, after|
    context "with the #{template} template" do
      it "gaps only the first definition paragraph below the designations" do
        expect(definition_spacing(template, "<p>One.</p><p>Two.</p>"))
          .to eq([["One.", "240", after], ["Two.", "0", after]])
      end

      it "gaps an inline definition below the designations" do
        expect(definition_spacing(template, "Inline."))
          .to eq([["Inline.", "240", after]])
      end
    end
  end
end
