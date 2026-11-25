# frozen_string_literal: true

require_relative "../spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  %i[dis simple].each do |template|
    context "with the #{template} template" do
      let(:xml) do
        minimal_iso_xml(<<~XML)
          <sections><terms id="terms"><title>Terms</title>
            <term id="t"><fmt-name>3.1</fmt-name>
              <termexample id="e"><fmt-name>EXAMPLE</fmt-name>#{body}</termexample>
            </term>
          </terms></sections>
        XML
      end
      let(:paragraphs) do
        scratch_dir = File.expand_path("../../../../tmp-fex", __dir__)
        FileUtils.mkdir_p(scratch_dir)
        Dir.mktmpdir("loose-", scratch_dir) do |dir|
          path = File.join(dir, "out.docx")
          build_adapter(template: template).convert(xml, path)
          extract_docx(path) { |doc, ns| doc.xpath("//w:body//w:p", ns) }
        end
      end
      let(:texts) { paragraphs.map { |p| p.xpath(".//w:t").map(&:text).join } }
      let(:example_paragraphs) do
        paragraphs.drop_while { |p| p.xpath(".//w:t").map(&:text).join != "EXAMPLE" }
      end

      context "with only loose text" do
        let(:body) { "JUSTTEXT" }

        it "keeps the loose text" do
          expect(texts.last(2)).to eq(%w[EXAMPLE JUSTTEXT])
        end

        it "uses the example body paragraph style" do
          style = example_paragraphs.last.at_xpath("w:pPr/w:pStyle/@w:val")&.value
          expect(style).to eq(template == :dis ? "Exampleindent" : "Example")
        end
      end

      context "with inline content around blocks" do
        let(:body) do
          "BEFORE<em>FIRST</em><p>PARA</p>LOOSE<em>EMX</em> END" \
            "<table id='tb'><tbody><tr><td>CELL</td></tr></tbody></table>" \
            "<strong>LAST</strong>AFTER"
        end

        it "keeps inline runs and blocks once in source order" do
          expect(texts.last(6)).to eq(["EXAMPLE", "BEFOREFIRST", "PARA", "LOOSEEMX END", "CELL", "LASTAFTER"])
        end

        it "styles loose content like the explicit example paragraph" do
          expected = template == :dis ? ["Exampleindent", *Array.new(3, "Exampleindentcontinued")] : Array.new(4, "Example")
          expect(example_paragraphs.values_at(1, 2, 3, 5).map { |p| p.at_xpath("w:pPr/w:pStyle/@w:val")&.value })
            .to eq(expected)
        end

        it "keeps italic formatting" do
          expect(example_paragraphs[3].xpath("w:r[w:rPr/w:i]/w:t").map(&:text).join).to eq("EMX")
        end

        it "keeps bold formatting" do
          expect(example_paragraphs.last.xpath("w:r[w:rPr/w:b]/w:t").map(&:text).join).to eq("LAST")
        end
      end

      context "with whitespace between blocks" do
        let(:body) { "\n  <p>ONE</p>\n  <p>TWO</p>\n" }

        it "does not create empty example paragraphs" do
          expect(example_paragraphs.map { |p| p.xpath(".//w:t").map(&:text).join })
            .to eq(%w[EXAMPLE ONE TWO])
        end
      end
    end
  end
end
