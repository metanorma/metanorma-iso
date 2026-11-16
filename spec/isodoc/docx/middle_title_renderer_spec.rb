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
        para_style_value(p) == "MainTitle1"
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
        para_style_value(p) == "MainTitle2"
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
        %w[MainTitle1 MainTitle2].include?(para_style_value(p))
      end

      expect(main_paras).to be_empty,
        "non-English titles should produce no MainTitle1/MainTitle2 paragraphs"
    end
  end

  # Amendment title block: "AMENDMENT 1: <description>" follows the part
  # title on the middle-title page. The submitted amendment artifacts
  # (mn-samples-iso rice-amd, ISO-accepted) carry the label + description
  # as a single title line; the classic chain emitted it as the
  # zzSTDTitle2 paragraph. Neither vendored template defines
  # zzSTDTitle2, so the line reuses MainTitle2 (the title family's
  # second line style). metanorma-iso#1728.
  it "renders the amendment label and description as a MainTitle2 line" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 17301-1:2016/Amd 1:2017</docidentifier>
        <title language="en" type="title-intro">Cereals and pulses</title>
        <title language="en" type="title-main">Specification and test methods</title>
        <title language="en" type="title-part">Rice</title>
        <title language="en" type="title-amendment-prefix">AMENDMENT&#xa0;1</title>
        <title language="en" type="title-amd">Mass fraction of extraneous matter</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      title_paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p) == "MainTitle2"
      end

      amd = title_paras.map do |p|
        Array(p.runs).map { |r| run_text(r) }.join
      end.find { |t| t.include?("AMENDMENT") }

      expect(amd).not_to be_nil,
        "the amendment title line must follow the part title; " \
        "MainTitle2 paragraphs: #{title_paras.map { |p| Array(p.runs).map { |r| run_text(r) }.join }.inspect}"
      expect(amd).to include("AMENDMENT"),
        "the amendment label must lead the line"
      expect(amd).to include("Mass fraction of extraneous matter"),
        "the amendment description must follow the label"
    end
  end

  it "renders the amendment description without a label when no prefix is given" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 17301-1:2016/Amd 1:2017</docidentifier>
        <title language="en" type="title-main">Rice</title>
        <title language="en" type="title-amd">Mass fraction of extraneous matter</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      amd_texts = pkg.document.body.paragraphs.select do |p|
        para_style_value(p) == "MainTitle2"
      end.map { |p| Array(p.runs).map { |r| run_text(r) }.join }

      expect(amd_texts).to include("Mass fraction of extraneous matter"),
        "a bare amendment description still renders on the title page; " \
        "got: #{amd_texts.inspect}"
    end
  end

  it "renders no amendment line for documents without amendment titles" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 17301-1:2023</docidentifier>
        <title language="en" type="title-main">Rice</title>
      </bibdata>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      amd_texts = pkg.document.body.paragraphs.map do |p|
        Array(p.runs).map { |r| run_text(r) }.join
      end.grep(/AMENDMENT/)

      expect(amd_texts).to be_empty,
        "non-amendment documents must not gain an amendment title line"
    end
  end
end
