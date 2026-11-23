# frozen_string_literal: true

require_relative "../spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  let(:adapter) { build_adapter }

  def definition_xml(body)
    minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title><term id="t"><fmt-name>3.1</fmt-name>
        <fmt-definition><semx element="definition" source="d">#{body}</semx></fmt-definition>
      </term></terms></sections>
    XML
  end

  def body_texts(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(definition_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:body//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
      end
    end
  end

  def definition_styles(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(definition_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='Definition']", ns)
            .map { |p| p.xpath(".//w:t", ns).map(&:text).join }
      end
    end
  end

  def formula_text(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(definition_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='Formula']//*[local-name()='t']", ns)
            .map(&:text).join
      end
    end
  end

  it "keeps each definition paragraph separate" do
    expect(definition_styles("<p>One.</p><p>Two.</p><p>Three.</p>")).to eq(%w[One. Two. Three.])
  end

  it "keeps a list between definition paragraphs in order" do
    texts = body_texts("<p>Before.</p><ul><li><p>Listed.</p></li></ul><p>After.</p>")
    expect(texts.grep(/Before|Listed|After/).map { |t| t[/Before\.|Listed\.|After\./] })
      .to eq(%w[Before. Listed. After.])
  end

  it "renders a definition that is only a list" do
    expect(body_texts("<ol><li><p>Only item.</p></li></ol>").join).to include("Only item.")
  end

  it "renders a definition list inside a definition" do
    xml = "<p>Lead.</p><dl><dt><p>key</p></dt><dd><p>value</p></dd></dl>"
    expect(body_texts(xml).join).to include("key", "value")
  end

  it "renders a table inside a definition" do
    xml = "<p>Lead.</p><table id='dt'><tbody><tr><td><p>Cell.</p></td></tr></tbody></table>"
    expect(body_texts(xml).join).to include("Cell.")
  end

  it "renders a quote inside a definition" do
    expect(body_texts("<p>Lead.</p><quote id='q'><p>Quoted.</p></quote>").join).to include("Quoted.")
  end

  it "renders a formula-only definition" do
    xml = "<formula id='f'><fmt-stem><semx element='stem' source='s'>" \
          "<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>x</mi></math>" \
          "</semx></fmt-stem></formula>"
    expect(formula_text(xml)).to include("x")
  end

  it "does not duplicate a single definition paragraph" do
    expect(definition_styles("<p>Single <strong>bold</strong>.</p>")).to eq(["Single bold."])
  end

  it "still renders an inline-only definition" do
    expect(definition_styles("Plain <em>inline</em> text")).to eq(["Plain inline text"])
  end
end
