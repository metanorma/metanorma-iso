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

  def middle_title_lines(xml)
    styles = %w[MainTitle1 MainTitle2]
    convert_and_extract(adapter, xml) do |pkg|
      paragraphs = pkg.document.body.paragraphs.select do |paragraph|
        styles.include?(para_style_value(paragraph))
      end
      return paragraphs.map do |paragraph|
        [para_style_value(paragraph), paragraph.runs.map { |run| run_text(run) }.join]
      end
    end
  end

  context "with only French titles" do
    let(:xml) do
      minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1</docidentifier>
          <language>fr</language>
          <title language="fr" type="main">Titre en français</title>
        </bibdata>
        <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      INNER
    end

    it "renders the French title" do
      expect(middle_title_lines(xml)).to eq([["MainTitle1", "Titre en français"]])
    end
  end

  context "with only English titles" do
    let(:xml) do
      minimal_iso_xml(<<~INNER)
        <bibdata>
          <docidentifier primary="true">ISO 1</docidentifier>
          <title language="en" type="main">English title</title>
        </bibdata>
        <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      INNER
    end

    it "renders the English title once" do
      expect(middle_title_lines(xml)).to eq([["MainTitle1", "English title"]])
    end
  end

  ["en", "fr"].each do |document_language|
    context "with bilingual titles and document language #{document_language}" do
      let(:xml) do
        minimal_iso_xml(<<~INNER)
          <bibdata>
            <docidentifier primary="true">ISO 1</docidentifier>
            <language>#{document_language}</language>
            <title language="en" type="main">English title</title>
            <title language="fr" type="main">Titre français</title>
          </bibdata>
          <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
        INNER
      end

      it "renders only the matching localized title" do
        expected = document_language == "en" ? "English title" : "Titre français"
        expect(middle_title_lines(xml)).to eq([["MainTitle1", expected]])
      end
    end
  end

  [false, true].each do |amendment|
    context "with bilingual titles defaulting to English#{' and amendment lines' if amendment}" do
      let(:titles) do
        <<~XML
          <title language="en" type="title-intro">Cereals and pulses</title>
          <title language="en" type="title-main">Rice</title>
          <title language="en" type="title-part-prefix">Part 1</title>
          <title language="en" type="title-part">Storage</title>
          <title language="fr" type="title-intro">Céréales et légumineuses</title>
          <title language="fr" type="title-main">Riz</title>
          <title language="fr" type="title-part-prefix">Partie 1</title>
          <title language="fr" type="title-part">Stockage</title>
        XML
      end
      let(:amendment_titles) do
        next "" unless amendment

        <<~XML
          <title language="en" type="title-amendment-prefix">AMENDMENT 1</title>
          <title language="en" type="title-amd">Storage conditions</title>
          <title language="fr" type="title-amendment-prefix">AMENDEMENT 1</title>
          <title language="fr" type="title-amd">Conditions de stockage</title>
        XML
      end
      let(:xml) do
        minimal_iso_xml(<<~INNER)
          <bibdata>#{titles}#{amendment_titles}</bibdata>
          <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
        INNER
      end
      let(:expected) do
        lines = [
          ["MainTitle1", "Cereals and pulses — Rice"],
          ["MainTitle2", "Part 1: Storage"],
        ]
        lines << ["MainTitle2", "AMENDMENT 1: Storage conditions"] if amendment
        lines
      end

      it "renders only the English block" do
        expect(middle_title_lines(xml)).to eq(expected)
      end
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
