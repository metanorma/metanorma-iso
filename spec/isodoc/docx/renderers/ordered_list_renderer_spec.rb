# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::OrderedListRenderer do
  let(:adapter) { build_adapter }

  it "renders ordered list items with decimal_list numId" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ol id="ol1" type="arabic">
            <li><p>One.</p></li>
            <li><p>Two.</p></li>
            <li><p>Three.</p></li>
          </ol>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      decimal_id = adapter.resolver.numbering_id(:decimal_list)
      list_paras = pkg.document.body.paragraphs.select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == decimal_id
      end

      expect(list_paras.length).to eq(3),
        "expected 3 decimal_list paragraphs, got #{list_paras.length}"

      texts = list_paras.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to eq(["One.", "Two.", "Three."])
    end
  end

  it "renders ordered list items without explicit <p> children" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ol id="ol1">
            <li>Bare item.</li>
          </ol>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      decimal_id = adapter.resolver.numbering_id(:decimal_list)
      list_paras = pkg.document.body.paragraphs.select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == decimal_id
      end

      expect(list_paras.length).to eq(1)
      text = list_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to eq("Bare item.")
    end
  end

  it "dispatches OrderedList via exact-class lookup" do
    registry = IsoDoc::Iso::Docx::Renderers::Registry.new do |r|
      r.register(
        Metanorma::Document::Components::Lists::OrderedList,
        :ordered_renderer,
      )
    end

    expect(registry.lookup(Metanorma::Document::Components::Lists::OrderedList))
      .to eq(:ordered_renderer)
  end
end
