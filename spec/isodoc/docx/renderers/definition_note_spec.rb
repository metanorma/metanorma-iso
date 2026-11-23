# frozen_string_literal: true

require_relative "../spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Adapter, "#convert definition list term notes", :aggregate_failures do
  let(:note) { "<termnote id='n1'><fmt-name>Note 1 to entry:</fmt-name><p>NOTEBODY</p></termnote>" }
  let(:dd) { "<p>FIRST</p>#{note}" }
  let(:dl) { "<dl id='dl'><dt>KEY</dt><dd>#{dd}</dd></dl>" }
  let(:inner) do
    "<terms id='ts'><title>Terms</title><term id='t'><preferred><expression><name>TERM</name>" \
      "</expression></preferred><definition><verbal-definition><p>LEAD</p>#{dl}" \
      "</verbal-definition></definition></term></terms>"
  end

  locations = %i[symbols cell]
  %i[dis simple].each do |variant|
    context "with #{variant} template" do
      let(:output) do
        xml = minimal_iso_xml("<sections>#{inner}</sections>")
        document = Dir.mktmpdir do |dir|
          path = File.join(dir, "definition-note.docx")
          build_adapter(template: variant).convert(xml, path)
          extract_docx(path) { |doc, _ns| doc }
        end
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        paragraphs = document.xpath("//w:body//w:p", ns)
        texts = paragraphs.map do |para|
          para.xpath(".//w:t | .//w:tab", ns).map { |node| node.name == "tab" ? "\t" : node.text }.join
        end
        { document: document, ns: ns, paragraphs: paragraphs,
          marked: texts.grep(/\AKEY\z|FIRST|LAST|NOTEBODY|SECONDNOTE|ORDINARY/) }
      end

      it "keeps a term note after its dd content with its label, tab and note style" do
        expect(output[:marked]).to eq(["KEY", "FIRST", "Note 1 to entry:\tNOTEBODY"])
        para = output[:paragraphs].find { |p| p.text.include?("NOTEBODY") }
        expect(para&.at_xpath("w:pPr/w:pStyle", output[:ns])&.[]("w:val")).to eq("Note")
      end

      context "with several paragraphs" do
        let(:dd) { "<p>FIRST</p><p>LAST</p>#{note}" }

        it "keeps the note after all paragraphs" do
          expect(output[:marked]).to eq(["KEY", "FIRST", "LAST", "Note 1 to entry:\tNOTEBODY"])
        end
      end

      context "with two notes" do
        let(:dd) do
          "<p>FIRST</p>#{note}<termnote id='n2'><fmt-name>Note 2 to entry:</fmt-name><p>SECONDNOTE</p></termnote>"
        end

        it "keeps both notes once in order" do
          expect(output[:marked]).to eq(["KEY", "FIRST", "Note 1 to entry:\tNOTEBODY", "Note 2 to entry:\tSECONDNOTE"])
        end
      end

      context "with a note between paragraphs" do
        let(:dd) { "<p>FIRST</p>#{note}<p>LAST</p>" }

        it "keeps source order" do
          expect(output[:marked]).to eq(["KEY", "FIRST", "Note 1 to entry:\tNOTEBODY", "LAST"])
        end
      end

      locations.each do |location|
        context "with a dd inside #{location}" do
          let(:inner) do
            if location == :symbols
              "<definitions id='sy'><title>Symbols</title>#{dl}</definitions>"
            else
              "<clause id='c'><title>Scope</title><table id='tb'><tbody><tr><td>#{dl}</td></tr></tbody></table></clause>"
            end
          end

          it "keeps the labeled styled note and ends every cell with a paragraph" do
            expect(output[:marked]).to eq(["KEY", "FIRST", "Note 1 to entry:\tNOTEBODY"])
            para = output[:paragraphs].find { |p| p.text.include?("NOTEBODY") }
            expect(para&.at_xpath("w:pPr/w:pStyle", output[:ns])&.[]("w:val")).to eq("Note")
            expect(output[:document].xpath("//w:tc", output[:ns]).map { |tc| tc.element_children.last.name }.uniq).to eq(["p"])
          end
        end
      end

      context "without a note" do
        let(:dd) { "<p>FIRST</p>" }

        it "preserves plain definition paragraphs" do
          expect(output[:marked]).to eq(%w[KEY FIRST])
          expect(output[:paragraphs].select { |p| p.text.match?(/\A(?:KEY|FIRST)\z/) }
            .map { |p| p.at_xpath("w:pPr/w:pStyle", output[:ns])["w:val"] }).to eq(%w[Definition Definition])
        end
      end

      context "with an ordinary note" do
        let(:dd) { "<p>FIRST</p><note id='n'><p>ORDINARY</p></note>" }

        it "preserves the ordinary note paragraph and style" do
          expect(output[:marked]).to eq(%w[KEY FIRST ORDINARY])
          para = output[:paragraphs].find { |p| p.text == "ORDINARY" }
          expect(para.at_xpath("w:pPr/w:pStyle", output[:ns])["w:val"]).to eq("Note")
        end
      end
    end
  end
end
