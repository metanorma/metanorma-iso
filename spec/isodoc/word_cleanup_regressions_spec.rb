require "spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::WordConvert do
  [described_class, IsoDoc::Iso::WordDISConvert].each do |renderer|
    context renderer.name do
      let(:converter) { renderer.new({}) }

      context "with a footnote body" do
        let(:doc) do
          Nokogiri::XML(<<~HTML)
            <html><body>
            <p>Body<a class="FootnoteRef" epub:type="footnote" href="#ftnnote">1</a></p>
            <aside id="ftnnote"><p><em>Text</em> continues.</p><p>Second paragraph.</p></aside>
            </body></html>
          HTML
        end
        let(:packaged) do
          converter.word_fn_cleanup(doc)
          converter.word_fn_cleanup(doc)
          Dir.mktmpdir do |dir|
            Html2Doc.new(filename: File.join(dir, "test")).footnotes(doc)
          end
          doc
        end
        let(:footnote) { packaged.at("//p[@class='MsoFootnoteText']") }

        it "separates the packaged footnote anchor from its body once" do
          expect(footnote.at("./a").next.text).to eq(" ")
        end

        it "preserves the automatic footnote number" do
          expect(footnote.at("./a/span[@class='MsoFootnoteReference']"))
            .not_to be_nil
        end

        it "preserves inline formatting" do
          expect(footnote.at("./em").text).to eq("Text")
        end

        it "preserves subsequent paragraphs" do
          expect(packaged.xpath("//p[@class='MsoFootnoteText']").last.text)
            .to eq("Second paragraph.")
        end
      end

      context "with existing footnote whitespace and table notes" do
        let(:doc) do
          Nokogiri::XML(<<~HTML)
            <html><body>
            <p><a class="FootnoteRef" href="#ftnspace">1</a>
            <a class="FootnoteRef" href="#ftnnbsp">2</a></p>
            <aside id="ftnspace"><p> Text</p></aside>
            <aside id="ftnnbsp"><p><em>&#160;Text</em></p></aside>
            <p><a class="TableFootnoteRef" href="#ftntable">a</a></p>
            <aside id="ftntable"><p>Table note</p></aside>
            <p>Ordinary text</p>
            </body></html>
          HTML
        end

        it "preserves existing leading footnote whitespace and table notes" do
          before = doc.to_xml
          converter.word_fn_cleanup(doc)
          expect(doc.to_xml).to eq(before)
        end
      end

      context "with an annex TOC variant" do
        let(:doc) do
          Nokogiri::XML(<<~HTML)
            <html><body><div class="Section3">
            <h1 class="Annex">Annex title</h1>
            <p style="display:none;" class="variant-title-toc">Annex A&#160; Annex title</p>
            <p>Annex body</p></div>
            <div><h1>Clause</h1><p class="variant-title-toc">Clause TOC title</p></div>
            </body></html>
          HTML
        end
        let(:toc) { converter.make_WordToC(doc, 2) }

        before do
          i18n = converter.i18n_init("en", "Latn", nil)
          converter.metadata_init("en", "Latn", nil, i18n)
          converter.instance_variable_set(:@iso_publisher, true)
        end

        it "keeps the full annex title in the Word TOC" do
          expect(Nokogiri::HTML.fragment(toc).text).to include("Annex A Annex title")
        end

        it "removes the HTML annex TOC variant after constructing the Word TOC" do
          toc
          converter.word_cleanup(doc)
          expect(doc.at("//div[@class='Section3']/p[@class='variant-title-toc']"))
            .to be_nil
        end

        it "preserves non-annex TOC variants" do
          converter.word_cleanup(doc)
          expect(doc.at("//p[@class='variant-title-toc']").text)
            .to eq("Clause TOC title")
        end

        it "preserves the annex heading and body" do
          converter.word_cleanup(doc)
          expect(doc.xpath("//div[@class='Section3']/p").map(&:text))
            .to eq(["Annex title", "Annex body"])
        end
      end
    end
  end
end
