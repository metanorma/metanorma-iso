# frozen_string_literal: true

require_relative "../spec_helper"

# Blocks that sit beside a term's notes, and blocks inside a term note,
# must reach the DOCX once, in source order, with their anchors.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  def term_xml(body)
    minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title>
        <term id="t"><fmt-name>3.1</fmt-name>
          <fmt-definition><semx element="definition" source="d"><p>Def para.</p></semx></fmt-definition>
          #{body}
        </term></terms></sections>
    XML
  end

  def convert(adapter, body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(term_xml(body), path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath("//w:body//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        styles = doc.xpath("//w:body//w:p/w:pPr/w:pStyle/@w:val", ns).map(&:value)
        return [texts, doc.xpath("//w:bookmarkStart/@w:name", ns).map(&:value), styles]
      end
    end
  end

  def order_of(texts, marks)
    texts.filter_map { |t| marks.find { |m| t.include?(m) } }
  end

  let(:beside_notes) do
    <<~XML
      <termnote id="n"><p>NOTETEXT</p></termnote>
      <sourcecode id="s">SRCTEXT</sourcecode>
      <quote id="q"><p>QUOTETEXT</p></quote>
      <admonition id="a" type="caution"><p>ADMONTEXT</p></admonition>
    XML
  end

  let(:inside_note) do
    <<~XML
      <termnote id="n"><p>NP1</p>
        <sourcecode id="ns">SRCINNOTE</sourcecode>
        <quote id="nq"><p>QINNOTE</p></quote>
        <ol id="nl"><li><p>NOL1</p></li></ol>
        <termexample id="ne"><p>EXINNOTE</p></termexample>
        <p>NPLAST</p>
      </termnote>
    XML
  end

  let(:plain) do
    <<~XML
      <termnote id="n"><p>NOTETEXT</p></termnote>
      <termexample id="e"><p>EXTEXT</p></termexample>
      <fmt-termsource>SOURCETEXT</fmt-termsource>
    XML
  end

  let(:formula) do
    "<formula id='f'><fmt-stem><semx element='stem' source='s'>" \
      "<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>FORMX</mi></math></semx></fmt-stem></formula>"
  end

  def note_xml(body)
    minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title>
        <note id="n"><fmt-name>NOTE</fmt-name>#{body}</note>
      </clause></sections>
    XML
  end

  def convert_note(adapter, body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(note_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:body//w:p", ns).map do |p|
          [p.at_xpath("w:pPr/w:pStyle/@w:val", ns)&.value, p.xpath(".//w:t", ns).map(&:text).join]
        end
      end
    end
  end

  %i[simple default].each do |template|
    context "with the #{template} template" do
      let(:adapter) { template == :default ? build_adapter : build_adapter(template: template) }

      it "renders term-level sourcecode, quote and admonition once, in order" do
        texts, = convert(adapter, beside_notes)
        expect(order_of(texts, %w[NOTETEXT SRCTEXT QUOTETEXT ADMONTEXT]))
          .to eq(%w[NOTETEXT SRCTEXT QUOTETEXT ADMONTEXT])
      end

      it "keeps the source order when a block precedes the note" do
        texts, = convert(adapter, '<quote id="q"><p>QUOTETEXT</p></quote><termnote id="n"><p>NOTETEXT</p></termnote>')
        expect(order_of(texts, %w[QUOTETEXT NOTETEXT])).to eq(%w[QUOTETEXT NOTETEXT])
      end

      it "gives a term-level sourcecode its anchor" do
        _, names = convert(adapter, '<sourcecode id="s">SRCTEXT</sourcecode>')
        expect(names).to include("s")
      end

      it "renders blocks inside a term note in order" do
        texts, = convert(adapter, inside_note)
        expect(order_of(texts, %w[NP1 SRCINNOTE QINNOTE NOL1 EXINNOTE NPLAST]))
          .to eq(%w[NP1 SRCINNOTE QINNOTE NOL1 EXINNOTE NPLAST])
      end

      it "renders a formula and sourcecode inside a term note in order" do
        _, _, styles = convert(adapter, "<termnote id='n'><p>NP1</p>#{formula}<sourcecode id='ns'>SRCINNOTE</sourcecode></termnote>")
        expect(styles.last(3)).to eq(%w[Note Formula Code])
      end

      it "renders sourcecode in a clause note in order, label apart when code is first" do
        paras = convert_note(adapter, "<sourcecode id='s'>CODEFIRST</sourcecode><p>AFTER</p>")
        expect(paras.map(&:last).grep(/NOTE|CODEFIRST|AFTER/)).to eq(%w[NOTE CODEFIRST AFTER])
      end

      it "renders sourcecode after a paragraph in a clause note" do
        paras = convert_note(adapter, "<p>BEFORE</p><sourcecode id='s'>CODELAST</sourcecode>")
        expect(paras.map(&:last).grep(/BEFORE|CODELAST/).map { |t| t[/BEFORE|CODELAST/] }).to eq(%w[BEFORE CODELAST])
      end

      it "keeps a leading quote in a clause note out of the label paragraph" do
        paras = convert_note(adapter, "<quote id='q'><p>QUOTEFIRST</p></quote><p>LAST</p>")
        expect(paras.map(&:last)).to include("QUOTEFIRST")
      end

      it "still renders plain notes, examples and sources in order" do
        texts, = convert(adapter, plain)
        expect(order_of(texts, %w[NOTETEXT EXTEXT SOURCETEXT])).to eq(%w[NOTETEXT EXTEXT SOURCETEXT])
      end
    end
  end
end
