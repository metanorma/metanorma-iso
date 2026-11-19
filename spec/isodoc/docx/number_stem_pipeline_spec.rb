# frozen_string_literal: true

require_relative "spec_helper"
require "asciidoctor"
require "metanorma-iso"

# Asciidoctor emits stem:[0] as <math><mstyle><mn>0</mn></mstyle></math>
# next to <asciimath>0</asciimath>. Large data tables (ISO 2533) carry
# ~141k of these; flattening them must not change the rendered cells.
RSpec.describe "DOCX number-stem flattening pipeline", type: :feature do
  let(:adapter_class) { IsoDoc::Iso::Docx::Adapter }
  let(:presxml) do
    adoc = <<~ADOC
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

      == Clause

      |===
      | stem:[0] | stem:[101325]
      |===
    ADOC
    IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", Asciidoctor.convert(adoc, backend: :iso, header_footer: true), true)
  end

  def math_count(xml)
    Nokogiri::XML(xml).xpath("//m:math", "m" => "http://www.w3.org/1998/Math/MathML").size
  end

  def cell_runs(adapter)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(presxml, path)
      extract_docx(path) do |doc, ns|
        doc.xpath("//w:tc//w:r", ns).map(&:to_xml)
      end
    end
  end

  it "drops the MathML count of stem:[0] and stem:[101325] to 0", :aggregate_failures do
    flattened = adapter_class.new.send(:flatten_number_stems, presxml)

    expect(math_count(presxml)).to be_positive
    expect(math_count(flattened)).to eq(0)
  end

  it "renders the same cell runs as without flattening", :aggregate_failures do
    unflattened = adapter_class.new
    allow(unflattened).to receive(:flatten_number_stems) { |xml| xml }
    flattened = cell_runs(adapter_class.new)

    expect(flattened.join).to include(">0<").and include(">101325<")
    expect(flattened).to eq(cell_runs(unflattened))
  end
end
