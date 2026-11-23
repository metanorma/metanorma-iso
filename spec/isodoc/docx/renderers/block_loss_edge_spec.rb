# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Adapter, "#convert block content-loss edges", :aggregate_failures do
  let(:w) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  def texts(inner)
    xml = minimal_iso_xml("<sections><clause id='c'><title>Scope</title>#{inner}</clause></sections>")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "o.docx")
      build_adapter.convert(xml, path)
      extract_docx(path) do |doc, _ns|
        doc.xpath("//w:body//w:p", w).map { |p| p.xpath(".//w:t", w).map(&:text).join }
      end
    end
  end

  it "prints figure preformatted text with child markup as text, not an Array literal" do
    out = texts("<figure id='f'><pre>one <strong>two</strong> three</pre></figure>")
    # The model maps only the <pre> text nodes, so the child's own text is
    # not recoverable; the surviving text must still print as plain text.
    expect(out).to include("one  three")
    expect(out.join).not_to include("[", "#<")
  end

  it "keeps a figure caption and key in a table cell" do
    out = texts("<table id='t'><tbody><tr><td><figure id='f'><fmt-name>FIGCAP</fmt-name><pre>PRETXT</pre></figure></td></tr></tbody></table>")
    expect(out.join).to include("FIGCAP", "PRETXT")
  end
end
