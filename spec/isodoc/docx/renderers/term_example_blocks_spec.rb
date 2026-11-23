# frozen_string_literal: true

require_relative "../spec_helper"

# Blocks inside a term example must reach the DOCX once, in source order,
# with the example label kept.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  def term_xml(example)
    minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title>
        <term id="t"><fmt-name>3.1</fmt-name>
          <fmt-definition><semx element="definition" source="d"><p>Def para.</p></semx></fmt-definition>
          #{example}
        </term></terms></sections>
    XML
  end

  def convert(adapter, example)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(term_xml(example), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:body//w:p", ns).map do |p|
          [p.at_xpath("w:pPr/w:pStyle/@w:val", ns)&.value, p.xpath(".//w:t", ns).map(&:text).join]
        end
      end
    end
  end

  def texts_of(paras, *marks)
    paras.map(&:last).filter_map { |t| marks.find { |m| t.include?(m) } }
  end

  let(:table) do
    "<table id='tb'><tbody><tr><td>CELLTEXT</td></tr></tbody></table>"
  end
  let(:formula) do
    "<formula id='f'><fmt-stem><semx element='stem' source='s'>" \
      "<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>FORMX</mi></math></semx></fmt-stem></formula>"
  end

  blocks_by_name = {
    "figure" => ["<figure id='fg'><fmt-name>FIGNAME</fmt-name><pre id='pr'>FIGTEXT</pre></figure>", "FIGNAME"],
    "quote" => ["<quote id='q'><p>QUOTETEXT</p></quote>", "QUOTETEXT"],
    "note" => ["<note id='n'><fmt-name>NOTE</fmt-name><p>NOTETEXT</p></note>", "NOTETEXT"],
    "admonition" => ["<admonition id='a' type='caution'><p>ADMONTEXT</p></admonition>", "ADMONTEXT"],
    "nested example" => ["<example id='ne'><fmt-name>EXAMPLE 2</fmt-name><p>NESTTEXT</p></example>", "NESTTEXT"],
  }.freeze

  def example(body)
    "<termexample id='e'><fmt-name>EXAMPLE</fmt-name>#{body}</termexample>"
  end

  %i[simple default].each do |template|
    context "with the #{template} template" do
      let(:adapter) { template == :default ? build_adapter : build_adapter(template: template) }

      let(:blocks) { "<p>EXP1</p>#{table}<sourcecode id='sc'>SRCTEXT</sourcecode>#{formula}<p>EXP2</p>" }

      it "renders a table, sourcecode and paragraphs once, in source order" do
        marks = %w[EXP1 CELLTEXT SRCTEXT EXP2]
        expect(texts_of(convert(adapter, example(blocks)), *marks)).to eq(marks)
      end

      it "renders the formula between the sourcecode and the last paragraph" do
        styles = convert(adapter, example(blocks)).map(&:first)
        expect(styles.last(3).first(2)).to eq(%w[Code Formula])
      end

      blocks_by_name.each do |name, (xml, marker)|
        it "renders a #{name} in a term example between paragraphs" do
          text = convert(adapter, example("<p>BEFORE</p>#{xml}<p>AFTER</p>")).map(&:last).join(" ")
          expect(text.scan(/BEFORE|#{marker}|AFTER/)).to eq(["BEFORE", marker, "AFTER"])
        end
      end

      it "keeps the literal text of a figure in a term example" do
        xml = "<figure id='fg'><fmt-name>FIGNAME</fmt-name><pre id='pr'>FIGTEXT</pre></figure>"
        paras = convert(adapter, example("<p>BEFORE</p>#{xml}<p>AFTER</p>"))
        expect(texts_of(paras, "BEFORE", "FIGTEXT", "FIGNAME", "AFTER"))
          .to eq(%w[BEFORE FIGTEXT FIGNAME AFTER])
      end

      it "renders both definition lists of a term example once, in order" do
        xml = "<dl id='d1'><dt>T1</dt><dd><p>DDONE</p></dd></dl><dl id='d2'><dt>T2</dt><dd><p>DDTWO</p></dd></dl>"
        text = convert(adapter, example(xml)).map(&:last).join(" ")
        expect(text.scan(/DDONE|DDTWO/)).to eq(%w[DDONE DDTWO])
      end

      it "keeps the example label" do
        paras = convert(adapter, example("<p>EXP1</p>#{table}"))
        expect(paras.map(&:last).join).to include("EXAMPLE")
      end

      it "leaves a single-paragraph example as label and text" do
        paras = convert(adapter, example("<p>ONLYPARA</p>"))
        expect(paras.map(&:last).grep(/EXAMPLE|ONLYPARA/)).to eq(%w[EXAMPLE ONLYPARA])
      end
    end
  end
end
