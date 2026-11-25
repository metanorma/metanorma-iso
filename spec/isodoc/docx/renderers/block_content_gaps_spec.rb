# frozen_string_literal: true

require_relative "../spec_helper"

# Block content must reach the document once, in source order, wherever a
# figure, formula key, symbols table or table-cell list holds it.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Adapter, "#convert block content", :aggregate_failures do
  def paragraphs(xml, template)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "gaps.docx")
      build_adapter(template: template).convert(xml, path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath("//w:body//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        return texts.reject { |text| text.strip.empty? }
      end
    end
  end

  def section(inner)
    minimal_iso_xml("<sections>#{inner}</sections>")
  end

  def marked(texts, pattern)
    texts.join(" ").scan(pattern)
  end

  let(:key_dd) do
    "<dd><p>KEYLEAD<note id='n1'><p>KEYNOTE</p></note></p>" \
      "<ul id='u1'><li><p>KEYITEM</p></li></ul>" \
      "<sourcecode id='s1'><body>KEYCODE</body><fmt-sourcecode>KEYCODE</fmt-sourcecode></sourcecode></dd>"
  end
  let(:all_marks) { /KEYTERM|KEYLEAD|KEYNOTE|KEYITEM|KEYCODE/ }
  let(:expected) { %w[KEYTERM KEYLEAD KEYNOTE KEYITEM KEYCODE] }

  %i[dis simple].each do |template|
    context "with template #{template}" do
      it "renders the text of a figure holding a literal block once" do
        xml = section("<clause id='c1'><title>Scope</title><figure id='f1'>" \
                      "<name>FIGNAME</name><pre id='p1'>LITLINE1\nLITLINE2</pre></figure></clause>")
        texts = paragraphs(xml, template)
        expect(marked(texts, /LITLINE1|LITLINE2|FIGNAME/)).to eq(%w[LITLINE1 LITLINE2 FIGNAME])
      end

      it "keeps a figure with an image-free name and no literal unchanged" do
        xml = section("<clause id='c1'><title>Scope</title><figure id='f1'><name>ONLYNAME</name></figure></clause>")
        expect(marked(paragraphs(xml, template), /ONLYNAME/)).to eq(%w[ONLYNAME])
      end

      it "renders blocks in a formula key dd once, in source order" do
        xml = section("<clause id='c1'><title>Scope</title><formula id='fm1'><stem type='AsciiMath'>" \
                      "<asciimath>x</asciimath></stem><key class='formula_dl'><dl id='d1'>" \
                      "<dt>KEYTERM</dt>#{key_dd}</dl></key></formula></clause>")
        expect(marked(paragraphs(xml, template), all_marks)).to eq(expected)
      end

      it "renders blocks in a symbols table dd once, in source order" do
        xml = section("<definitions id='d0'><title>Symbols</title><dl id='d1'>" \
                      "<dt>KEYTERM</dt>#{key_dd}</dl></definitions>")
        expect(marked(paragraphs(xml, template), all_marks)).to eq(expected)
      end

      it "renders a note embedded in a symbols table list item once, after its text" do
        xml = section("<definitions id='d0'><title>Symbols</title><dl id='d1'><dt>SYM</dt><dd><p>LEAD</p>" \
                      "<ul id='u1'><li><p>ITEMTEXT<note id='n1'><p>ITEMNOTE</p></note></p></li></ul></dd></dl></definitions>")
        expect(marked(paragraphs(xml, template), /ITEMTEXT|ITEMNOTE/)).to eq(%w[ITEMTEXT ITEMNOTE])
      end

      it "keeps a plain symbols table dd as one cell paragraph" do
        xml = section("<definitions id='d0'><title>Symbols</title><dl id='d1'>" \
                      "<dt>SYM</dt><dd><p>PLAIN</p></dd></dl></definitions>")
        expect(paragraphs(xml, template).grep(/\A(SYM|PLAIN)\z/)).to eq(%w[SYM PLAIN])
      end

      it "keeps a nested dl in the last list item, with no literal marker" do
        xml = section("<clause id='c1'><title>Scope</title><ul id='u1'><li><p>FIRST</p></li>" \
                      "<li><p>LAST</p><dl id='d1'><dt>ALPHA</dt><dd><p>AA</p></dd></dl></li></ul></clause>")
        texts = paragraphs(xml, template)
        expect(marked(texts, /FIRST|LAST|ALPHA|AA/)).to eq(%w[FIRST LAST ALPHA AA])
        expect(texts.grep(/\+/)).to be_empty
      end
    end
  end
end
