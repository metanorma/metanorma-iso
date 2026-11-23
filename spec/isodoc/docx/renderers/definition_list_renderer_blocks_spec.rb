# frozen_string_literal: true

require_relative "../spec_helper"

# A dd may hold several paragraphs, lists, notes and other blocks; each
# must reach the document once, in source order, as its own block.
RSpec.describe IsoDoc::Iso::Docx::Renderers::DefinitionListRenderer, :aggregate_failures do
  let(:components) { Metanorma::Document::Components }
  let(:marks) { /KEYTERM|FIRSTPARA|SECONDPARA|LISTITEM|LASTPARA/ }
  let(:rich_dd) do
    "<dl id='d1'><dt>KEYTERM</dt><dd><p>FIRSTPARA</p><p>SECONDPARA</p>" \
      "<ul id='u1'><li><p>LISTITEM</p></li></ul><p>LASTPARA</p></dd></dl>"
  end

  def paragraphs(xml, template, xpath = "//w:body//w:p")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "dl.docx")
      build_adapter(template: template).convert(xml, path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath(xpath, ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        return texts.reject { |text| text.strip.empty? }
      end
    end
  end

  def clause(inner)
    minimal_iso_xml("<sections><clause id='c1'><title>Scope</title>#{inner}</clause></sections>")
  end

  def term(inner)
    minimal_iso_xml("<sections><terms id='ts'><title>Terms</title><term id='t1'><preferred>" \
                    "<expression><name>TN</name></expression></preferred><definition id='df'>" \
                    "<verbal-definition><p>LEAD</p>#{inner}</verbal-definition></definition></term></terms></sections>")
  end

  def table(inner)
    clause("<table id='t1'><tbody><tr><td>#{inner}</td></tr></tbody></table>")
  end

  def marked(texts)
    texts.grep(marks).map { |t| t[marks] }
  end

  %i[dis simple].each do |template|
    context "with template #{template}" do
      it "keeps each dd paragraph and list separate, once, in order" do
        texts = paragraphs(clause(rich_dd), template)
        expect(marked(texts)).to eq(%w[KEYTERM FIRSTPARA SECONDPARA LISTITEM LASTPARA])
        expect(texts.grep(/FIRSTPARA.*SECONDPARA/)).to be_empty
      end

      it "renders a note and a source block inside a dd once" do
        dd = "<dd><p>DDTEXT</p><note id='n1'><p>DDNOTE</p></note>" \
             "<sourcecode id='s1'><body>DDCODE</body></sourcecode></dd>"
        text = paragraphs(clause("<dl id='d1'><dt>K</dt>#{dd}</dl>"), template).join(" ")
        expect(text.scan(/DDTEXT|DDNOTE|DDCODE/)).to eq(%w[DDTEXT DDNOTE DDCODE])
      end

      it "renders a note embedded in a dd paragraph once, after its text" do
        dd = "<dd><p>DDLEAD<note id='n1'><p>EMBNOTE</p></note></p></dd>"
        texts = paragraphs(clause("<dl id='d1'><dt>K</dt>#{dd}</dl>"), template)
        expect(texts.grep(/DDLEAD|EMBNOTE/).map { |t| t[/DDLEAD|EMBNOTE/] }).to eq(%w[DDLEAD EMBNOTE])
      end

      it "leaves a single-paragraph dd as one paragraph" do
        texts = paragraphs(clause("<dl id='d1'><dt>K</dt><dd><p>ONLY</p></dd></dl>"), template)
        expect(texts.grep(/\A(K|ONLY)\z/)).to eq(%w[K ONLY])
      end

      it "renders a source block in a table cell once" do
        code = "<sourcecode id='s1'><body>INCELL</body><fmt-sourcecode>INCELL</fmt-sourcecode></sourcecode>"
        expect(paragraphs(table(code), template).join(" ").scan("INCELL").size).to eq(1)
      end

      it "renders a dl with block dd inside a table cell" do
        texts = paragraphs(table(rich_dd), template)
        expect(marked(texts)).to eq(%w[KEYTERM FIRSTPARA SECONDPARA LISTITEM LASTPARA])
        expect(texts.grep(/FIRSTPARA.*SECONDPARA/)).to be_empty
      end

      it "renders a dd with several blocks inside a term definition" do
        texts = paragraphs(term(rich_dd), template)
        expect(marked(texts)).to eq(%w[KEYTERM FIRSTPARA SECONDPARA LISTITEM LASTPARA])
        expect(texts.grep(/FIRSTPARA.*SECONDPARA/)).to be_empty
      end
    end
  end

  describe "cell note blocks" do
    let(:handler_class) { IsoDoc::Iso::Docx::Renderers::TableCellElement::NoteHandler }

    it "keeps each paragraph of a multi-paragraph cell note, without an added space" do
      note = "<note id='n'><p>PARAONE</p><p>PARATWO</p></note>"
      texts = paragraphs(table(note), :dis, "//w:tc//w:p")
      expect(texts.grep(/PARA/)).to eq(%w[PARAONE PARATWO])
    end

    def stubbed_note_handler(note, children, seen)
      handler = handler_class.new(resolver: nil, inline_renderer: double(context: nil),
                                  dispatcher: ->(element, _target) { seen << element })
      allow(handler).to receive(:block_children).with(note).and_return(children)
      allow(handler).to receive(:render_paragraph)
      handler
    end

    # Stubbed: the model gem's NoteBlock does not yet parse <sourcecode>,
    # so the note's children are supplied directly.
    it "dispatches a sourcecode child of a cell note to the cell dispatcher" do
      source = components::AncillaryBlocks::SourcecodeBlock.new
      note = components::Blocks::NoteBlock.new
      seen = []
      stubbed_note_handler(note, [source], seen).render(note, nil)
      expect(seen).to eq([source])
    end
  end
end
