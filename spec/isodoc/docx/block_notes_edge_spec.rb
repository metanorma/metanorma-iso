# frozen_string_literal: true

require_relative "spec_helper"

# Notes, examples and list definitions that sit in less common places must
# reach the DOCX, as they do in the DOC output.
RSpec.describe IsoDoc::Iso::Docx::Adapter do # rubocop:disable RSpec/SpecFilePathFormat
  let(:adapter) { build_adapter }
  let(:nested_example) do
    "<termexample id='e'><fmt-name>EXAMPLE 1</fmt-name><p>OUTER</p>" \
      "<termnote id='tn'><fmt-name>Note 1 to entry: </fmt-name><p>INNERNOTE</p></termnote>" \
      "<termexample id='e2'><fmt-name>EXAMPLE</fmt-name><p>INNEREX</p></termexample>" \
      "</termexample>"
  end

  def paragraphs(body)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(minimal_iso_xml(body), path)
      extract_docx(path) do |doc, ns|
        return doc.xpath("//w:body//w:p", ns).map do |p|
          style = p.at_xpath("w:pPr/w:pStyle/@w:val", ns)&.value
          before = p.at_xpath("w:pPr/w:spacing/@w:before", ns)&.value
          nodes = p.xpath(".//w:t | .//w:tab", ns)
          text = nodes.map { |n| n.name == "tab" ? "\t" : n.text }.join
          { style: style, before: before, text: text }
        end
      end
    end
  end

  def clause(inner)
    "<sections><clause id='c'><title>Scope</title>#{inner}</clause></sections>"
  end

  def terms(term_inner)
    "<sections><terms id='ts'><title>Terms</title>" \
      "<term id='t'><fmt-name>3.1</fmt-name>" \
      "<fmt-preferred><p><strong>word</strong></p></fmt-preferred>#{term_inner}" \
      "</term></terms></sections>"
  end

  def note(text)
    "<note id='n'><fmt-name>NOTE<tab/></fmt-name><p>#{text}</p></note>"
  end

  it "keeps a note inside a formula" do
    formula = "<formula id='f'><fmt-stem><semx element='stem' source='s'>" \
              "<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>x</mi></math>" \
              "</semx></fmt-stem>#{note('FORMNOTE')}</formula>"
    paras = paragraphs(clause(formula))
    expect(paras.map { |p| p[:text] }.grep(/FORMNOTE/).size).to eq(1)
  end

  it "keeps a note inside a quote paragraph" do
    quote = "<quote id='q'><p>QTEXT#{note('QNOTE')}</p></quote>"
    texts = paragraphs(clause(quote)).map { |p| p[:text] }
    expect(texts.grep(/QTEXT|QNOTE/)).to match([/QTEXT/, /QNOTE/])
  end

  it "keeps a note inside an admonition paragraph" do
    tip = "<admonition id='a' type='tip'><p>ATEXT#{note('ANOTE')}</p></admonition>"
    texts = paragraphs(clause(tip)).map { |p| p[:text] }
    expect(texts.grep(/ATEXT|ANOTE/)).to match([/ATEXT/, /ANOTE/])
  end

  it "separates the label of an example in a table cell with a tab" do
    example = "<example id='e'><fmt-name>EXAMPLE<tab/></fmt-name><p>CELLEX</p></example>"
    table = "<table id='tb'><tbody><tr><td>#{example}</td></tr></tbody></table>"
    para = paragraphs(clause(table)).find { |p| p[:text].include?("CELLEX") }
    expect(para[:text]).to eq("EXAMPLE\tCELLEX")
  end

  it "spaces a list definition from the designations like a definition paragraph" do
    list = "<fmt-definition><semx element='definition' source='d'>" \
           "<ul id='u'><li><p>LISTDEF</p></li></ul></semx></fmt-definition>"
    para = paragraphs(terms(list)).find { |p| p[:text].include?("LISTDEF") }
    expect(para[:before]).to eq("240")
  end

  it "keeps a term note and a term example nested in a term example" do
    texts = paragraphs(terms(nested_example)).map { |p| p[:text] }
    expect(texts.grep(/OUTER|INNER/)).to match([/OUTER/, /INNERNOTE/, /INNEREX/])
  end
end
