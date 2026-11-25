require "spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::WordConvert do
  [described_class, IsoDoc::Iso::WordDISConvert].each do |renderer|
    context renderer.name do
      let(:converter) { renderer.new({}) }
      let(:doc) do
        Nokogiri::XML(<<~HTML)
          <html xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"><body>
          <p>A<a class="FootnoteRef" href="#ftnstem">1</a>
          B<a class="FootnoteRef" href="#ftnimg">2</a>
          C<a class="FootnoteRef" href="#ftnspace">3</a>
          D<a class="FootnoteRef" href="#ftnlist">4</a>
          E<a class="FootnoteRef" href="#ftntable">5</a>
          F<a class="FootnoteRef" href="#ftnmathml">6</a></p>
          <aside id="ftnstem"><p><span class="stem"><m:oMath> <m:r><m:t>x</m:t></m:r></m:oMath></span> math.</p></aside>
          <aside id="ftnmathml"><p><span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML"> <mi>x</mi> </math></span> math.</p></aside>
          <aside id="ftnimg"><p><img src="a.png"/> image.</p></aside>
          <aside id="ftnspace"><p> text.</p></aside>
          <aside id="ftnlist"><ul><li><p>item</p></li></ul></aside>
          <aside id="ftntable"><table><tr><td><p>cell</p></td></tr></table></aside>
          </body></html>
        HTML
      end

      def leading_text(id)
        doc.at("//aside[@id='#{id}']").text
      end

      before { converter.word_fn_cleanup(doc) }

      it "puts the space before a leading stem, not inside its math" do
        expect(doc.at("//aside[@id='ftnstem']/p").children.first.text).to eq(" ")
      end

      it "puts the space before leading MathML" do
        expect(doc.at("//aside[@id='ftnmathml']/p").children.first.text).to eq(" ")
      end

      it "leaves the math content untouched" do
        expect(doc.at("//*[local-name()='oMath']").children.first.text).to eq(" ")
      end

      it "puts a space before a leading image" do
        expect(doc.at("//aside[@id='ftnimg']/p").children.first.text).to eq(" ")
      end

      it "adds no second space to a footnote that already starts with one" do
        expect(leading_text("ftnspace")).to eq(" text.")
      end

      it "spaces a footnote that starts with a list" do
        expect(leading_text("ftnlist")).to start_with(" item")
      end

      it "spaces a footnote that starts with a table" do
        expect(leading_text("ftntable")).to start_with(" cell")
      end
    end
  end
end
