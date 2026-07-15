# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::IndexsectRenderer do
  let(:adapter) { build_adapter }

  it "renders indexsect title with IndexHead style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      <indexsect id="idx">
        <title>Index</title>
        <p>Subject index entries.</p>
      </indexsect>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      index_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "IndexHead"
      end

      expect(index_paras.length).to eq(1),
        "indexsect title should render with IndexHead style"

      text = index_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("Index")
    end
  end

  it "renders indexsect with index entries" do
    xml = minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      <indexsect id="idx">
        <title>Index</title>
        <index id="ix1"><primary>Alpha</primary></index>
      </indexsect>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      index_title_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "IndexHead"
      end

      expect(index_title_paras.length).to eq(1),
        "indexsect title should render with IndexHead style"
    end
  end
end
