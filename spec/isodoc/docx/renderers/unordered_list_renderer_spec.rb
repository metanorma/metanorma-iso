# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::UnorderedListRenderer do
  let(:adapter) { build_adapter }

  it "renders unordered list items with dash_list numId" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ul id="ul1">
            <li><p>First item.</p></li>
            <li><p>Second item.</p></li>
          </ul>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      list_paras = pkg.document.body.paragraphs.select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == adapter.resolver.numbering_id(:dash_list)
      end

      expect(list_paras.length).to eq(2),
        "expected 2 dash_list paragraphs, got #{list_paras.length}"

      texts = list_paras.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("First item.")
      expect(texts).to include("Second item.")
    end
  end

  it "applies ListContinue1 style to unordered list items" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ul id="ul1">
            <li><p>First item.</p></li>
            <li><p>Second item.</p></li>
          </ul>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
      list_continue_count = styles.count("ListContinue1")
      expect(list_continue_count).to eq(2),
        "expected 2 ListContinue1 paragraphs, got #{list_continue_count}"
    end
  end

  it "renders list items without explicit <p> children" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ul id="ul1">
            <li>Bare text item.</li>
          </ul>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      dash_id = adapter.resolver.numbering_id(:dash_list)
      list_paras = pkg.document.body.paragraphs.select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == dash_id
      end

      expect(list_paras.length).to eq(1)
      text = list_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to eq("Bare text item.")
    end
  end

  it "renders multiple paragraphs inside a single list item" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ul id="ul1">
            <li>
              <p>First paragraph.</p>
              <p>Second paragraph.</p>
            </li>
          </ul>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      dash_id = adapter.resolver.numbering_id(:dash_list)
      list_paras = pkg.document.body.paragraphs.select do |p|
        num_pr = p.properties&.numbering_properties
        num_pr&.num_id&.value == dash_id
      end

      expect(list_paras.length).to eq(1),
        "multi-paragraph item should still be one numbering paragraph"

      text = list_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("First paragraph.")
      expect(text).to include("Second paragraph.")
    end
  end

  it "dispatches UnorderedList via exact-class lookup" do
    registry = IsoDoc::Iso::Docx::Renderers::Registry.new do |r|
      r.register(
        Metanorma::Document::Components::Lists::UnorderedList,
        :unordered_renderer,
      )
    end

    expect(registry.lookup(Metanorma::Document::Components::Lists::UnorderedList))
      .to eq(:unordered_renderer)
  end
end
