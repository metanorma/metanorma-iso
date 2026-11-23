# frozen_string_literal: true

require_relative "../spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Adapter, "#convert definition block preservation", :aggregate_failures do
  let(:dd) { "<p>FIRST</p><termnote id='n1'><fmt-name>Note 1 to entry:</fmt-name><p>NOTEBODY</p></termnote>" }
  let(:dl) { "<dl><dt>KEY</dt><dd>#{dd}</dd></dl>" }
  let(:inner) { "<clause id='c'><title>Scope</title>#{dl}</clause>" }
  let(:output) do
    xml = minimal_iso_xml("<sections>#{inner}</sections>")
    document = Dir.mktmpdir do |dir|
      path = File.join(dir, "definition-blocks.docx")
      build_adapter(template: template).convert(xml, path)
      extract_docx(path) { |doc, _ns| doc }
    end
    ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
    paragraphs = document.xpath("//w:body//w:p", ns)
    marked = paragraphs.map do |para|
      para.xpath(".//w:t | .//w:tab", ns).map { |node| node.name == "tab" ? "\t" : node.text }.join
    end.grep(/\AKEY\z|FIRST|CELLX|NOTEBODY|TAIL|ORDINARY/)
    { document: document, ns: ns, paragraphs: paragraphs, marked: marked }
  end

  shared_examples "a styled term note" do |expected, pending_reason|
    it "keeps the label, tab and body in source order with Note style" do
      pending(pending_reason) if pending_reason
      expect(output[:marked]).to eq(expected)
      para = output[:paragraphs].find { |p| p.text.include?("NOTEBODY") }
      expect(para&.at_xpath("w:pPr/w:pStyle", output[:ns])&.[]("w:val")).to eq("Note")
      expect(output[:document].xpath("//w:tc", output[:ns]).map { |tc| tc.element_children.last.name }.uniq - ["p"]).to be_empty
    end
  end

  variants = %i[dis simple]
  variants.each do |variant|
    context "with #{variant} template" do
      let(:template) { variant }

      table_locations = %i[symbols formula]
      table_locations.each do |location|
        context "with a nested table in a #{location} definition" do
          let(:dd) { "<p>FIRST</p><table><tbody><tr><td>CELLX</td></tr></tbody></table>" }
          let(:inner) do
            if location == :symbols
              "<definitions><title>Symbols</title>#{dl}</definitions>"
            else
              "<clause id='c'><title>Scope</title><formula><stem>x</stem>#{dl}</formula></clause>"
            end
          end

          it "keeps the table after the paragraph and ends every cell with a paragraph" do
            expect(output[:marked]).to eq(%w[KEY FIRST CELLX])
            expect(output[:document].xpath("//w:tc", output[:ns]).map { |tc| tc.element_children.last.name }.uniq).to eq(["p"])
            expect(output[:document].xpath("//w:tc/w:tbl", output[:ns]).size).to eq(1)
          end
        end
      end

      context "with a figure key" do
        let(:inner) { "<clause id='c'><title>Scope</title><figure><pre>x</pre>#{dl}</figure></clause>" }

        it_behaves_like "a styled term note", ["KEY", "FIRST", "Note 1 to entry: NOTEBODY"], nil
      end

      context "with a figure key without blocks" do
        let(:inner) { "<clause id='c'><title>Scope</title><figure><pre>x</pre>#{dl}</figure></clause>" }
        let(:dd) { "<p>FIRST</p>" }

        it "keeps the key term and definition as key paragraphs" do
          expect(output[:marked]).to eq(%w[KEY FIRST])
          styles = %w[KEY FIRST].map do |text|
            output[:paragraphs].find { |p| p.text == text }.at_xpath("w:pPr/w:pStyle", output[:ns])&.[]("w:val")
          end
          expect(styles).to eq(variant == :dis ? %w[KeyTitle KeyText] : [nil, nil])
        end
      end

      note_locations = %i[general symbols]
      note_locations.each do |location|
        context "with a term note embedded in a #{location} definition paragraph" do
          let(:dd) do
            "<p>FIRST<termnote id='n1'><fmt-name>Note 1 to entry:</fmt-name><p>NOTEBODY</p></termnote>TAIL</p>"
          end
          let(:inner) do
            if location == :symbols
              "<definitions><title>Symbols</title>#{dl}</definitions>"
            else
              "<clause id='c'><title>Scope</title>#{dl}</clause>"
            end
          end

          it_behaves_like "a styled term note", ["KEY", "FIRST", "Note 1 to entry: NOTEBODY", "TAIL"], nil
        end
      end
    end
  end
end
