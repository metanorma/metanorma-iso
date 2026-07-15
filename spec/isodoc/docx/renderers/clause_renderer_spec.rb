# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ClauseRenderer do
  let(:adapter) { build_adapter }

  it "renders clause title with Heading1 at depth 1" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value.to_s.start_with?("Heading")
      end
      expect(heading_paras.map { |p| p.properties.style.value })
        .to include("Heading1"),
        "top-level clause title should use Heading1, got: #{heading_paras.inspect}"
    end
  end

  it "nests clause depth (Heading2 under Heading1)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Top</title>
          <clause id="c1a"><title>Sub</title><p>Body.</p></clause>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value.to_s.start_with?("Heading")
      end
      levels = heading_paras.map { |p| p.properties.style.value }
      expect(levels).to include("Heading1"),
        "top-level should be Heading1, got: #{levels.inspect}"
      expect(levels).to include("Heading2"),
        "nested should be Heading2, got: #{levels.inspect}"
    end
  end

  it "walks child content after rendering title" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>Body paragraph one.</p>
          <p>Body paragraph two.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.flat_map { |p| p.runs.map(&:text).compact }
      joined = texts.join
      expect(joined).to include("Body paragraph one")
      expect(joined).to include("Body paragraph two")
    end
  end
end
