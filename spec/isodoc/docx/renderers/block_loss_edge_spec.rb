# frozen_string_literal: true

require_relative "../spec_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Adapter, "#convert block content-loss edges", :aggregate_failures do
  let(:w) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:math) { "<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>x</mi></math>" }
  let(:cell_example) do
    "<example id='e'><name>HIDDENNAME</name><fmt-name>EXAMPLE 1</fmt-name><p>CELLEX</p></example>"
  end
  let(:symbols_formula) do
    "<definitions id='d'><title>Symbols</title>" \
      "<dl><dt>SYMA</dt><dd><p>DEFA</p></dd></dl>" \
      "<formula id='f'><fmt-stem><semx element='stem' source='s'>#{math}</semx></fmt-stem>" \
      "<dl><dt>KEYB</dt><dd><p>KEYDEF</p></dd></dl></formula></definitions>"
  end

  # Paragraph texts of the converted body.
  def texts(sections)
    xml = minimal_iso_xml("<sections>#{sections}</sections>")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      build_adapter.convert(xml, path)
      extract_docx(path) do |doc, _ns|
        doc.xpath("//w:body//w:p", w).map { |p| p.xpath(".//w:t", w).map(&:text).join }
      end
    end
  end

  def clause(inner)
    texts("<clause id='c'><title>Scope</title>#{inner}</clause>")
  end

  def cell(inner)
    clause("<table id='t'><tbody><tr><td>#{inner}</td></tr></tbody></table>")
  end

  def term(entry)
    texts('<terms id="terms"><title>Terms</title><term id="t"><fmt-name>3.1</fmt-name>' \
          '<fmt-definition><semx element="definition" source="d"><p>DEFTEXT</p></semx></fmt-definition>' \
          "#{entry}</term></terms>")
  end

  it "prints figure preformatted text with child markup as text, not an Array literal" do
    out = clause("<figure id='f'><pre>one <strong>two</strong> three</pre></figure>")
    expect(out).to include("one two three")
    expect(out.join).not_to include("[", "#<")
  end

  it "keeps a figure caption and body in a table cell" do
    out = cell("<figure id='f'><fmt-name>FIGCAP</fmt-name><pre>PRETXT</pre></figure>")
    expect(out.join).to include("FIGCAP", "PRETXT")
  end

  it "keeps a termnote inside a termexample" do
    out = term("<termexample id='e'><p>EXBODY</p><termnote id='n'><p>NESTNOTE</p></termnote></termexample>")
    expect(out.join).to include("EXBODY", "NESTNOTE")
  end

  it "keeps a termexample inside a definition list item" do
    out = term("<termnote id='n'><dl><dt>KEYT</dt><dd><p>DDPARA</p>" \
               "<termexample id='e'><p>DDEXAMPLE</p></termexample></dd></dl></termnote>")
    expect(out.join).to include("DDPARA", "DDEXAMPLE")
  end

  it "keeps a termexample inside a definition list item in a table cell" do
    out = cell("<dl id='d'><dt>KEYT</dt><dd><p>DDPARA</p>" \
               "<termexample id='e'><p>DDEXAMPLE</p></termexample></dd></dl>")
    expect(out.join).to include("DDPARA", "DDEXAMPLE")
  end

  it "prints a table cell example label once and not the hidden name" do
    out = cell(cell_example).join
    expect(out).to include("CELLEX")
    expect(out).not_to include("HIDDENNAME")
    expect(out.scan("EXAMPLE 1").size).to eq(1)
  end

  it "keeps each paragraph of a table cell list item as its own paragraph" do
    out = cell("<ul id='u'><li><p>FIRSTPARA</p><p>SECONDPARA</p></li></ul>")
    expect(out).to include("FIRSTPARA", "SECONDPARA")
  end

  it "keeps a formula key that follows a definition list in Symbols" do
    out = texts(symbols_formula).join(" ")
    expect(out).to include("SYMA", "DEFA", "KEYB", "KEYDEF")
  end
end
