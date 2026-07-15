# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::MiddleTitleRenderer do
  let(:adapter) { build_adapter }

  it "renders title intro+main with MainTitle1 style" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <title language="en" type="main">Rice</title>
        <title language="en" type="intro">Cereals and pulses</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      main_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "MainTitle1"
      end

      expect(main_paras.length).to eq(1),
        "expected one MainTitle1 paragraph for intro+main title"

      text = main_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("Cereals and pulses"),
        "intro title should appear in MainTitle1 paragraph"
      expect(text).to include("Rice"),
        "main title should appear in MainTitle1 paragraph"
    end
  end

  it "renders title-part with MainTitle2 style" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <title language="en" type="main">Rice</title>
        <title language="en" type="title-part">Storage</title>
        <title language="en" type="title-part-prefix">Part 1</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      part_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "MainTitle2"
      end

      expect(part_paras.length).to eq(1),
        "expected one MainTitle2 paragraph for title-part"

      text = part_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("Part 1"),
        "title-part-prefix should appear in MainTitle2 paragraph"
      expect(text).to include("Storage"),
        "title-part value should appear in MainTitle2 paragraph"
    end
  end

  it "renders no title paragraphs when bibdata has no English titles" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 1</docidentifier>
        <title language="fr" type="main">Titre en français</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      main_paras = pkg.document.body.paragraphs.select do |p|
        %w[MainTitle1 MainTitle2].include?(p.properties&.style&.value)
      end

      expect(main_paras).to be_empty,
        "non-English titles should produce no MainTitle1/MainTitle2 paragraphs"
    end
  end
end
