# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::PrefaceRenderer do
  let(:adapter) { build_adapter }

  it "renders foreword title with ForewordTitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <preface>
        <foreword id="fw" obligation="informative">
          <title>Foreword</title>
          <p>ISO draws attention to ...</p>
        </foreword>
      </preface>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      foreword_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "ForewordTitle"
      end

      expect(foreword_paras.length).to eq(1),
        "foreword title should be styled with 'ForewordTitle' style"

      text = foreword_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("Foreword")
    end
  end

  it "renders introduction title with IntroTitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <preface>
        <introduction id="intro" obligation="informative">
          <title>Introduction</title>
          <p>Some intro text.</p>
        </introduction>
      </preface>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      intro_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "IntroTitle"
      end

      expect(intro_paras.length).to eq(1),
        "introduction title should be styled with 'IntroTitle' style"
    end
  end

  it "skips preface clauses whose type is toc" do
    xml = minimal_iso_xml(<<~INNER)
      <preface>
        <foreword id="fw" obligation="informative">
          <title>Foreword</title>
          <p>Foreword body.</p>
        </foreword>
        <clause id="toc-clause" type="toc">
          <title>Table of Contents</title>
          <p>Should not render twice.</p>
        </clause>
      </preface>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      body_text = pkg.document.body.paragraphs.map do |p|
        p.runs.map { |r| r.text || "" }.join
      end.join

      expect(body_text).not_to include("Should not render twice."),
        "preface TOC clause should not be re-rendered (TocBuilder owns it)"
    end
  end

  it "renders non-toc preface clauses via dispatcher" do
    xml = minimal_iso_xml(<<~INNER)
      <preface>
        <foreword id="fw" obligation="informative">
          <title>Foreword</title>
          <p>Foreword body.</p>
        </foreword>
        <clause id="ack" obligation="informative">
          <title>Acknowledgements</title>
          <p>Special thanks.</p>
        </clause>
      </preface>
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      body_text = pkg.document.body.paragraphs.map do |p|
        p.runs.map { |r| r.text || "" }.join
      end.join

      expect(body_text).to include("Special thanks."),
        "non-toc preface clause body should render"
    end
  end
end
