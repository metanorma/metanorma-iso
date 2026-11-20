# frozen_string_literal: true

require_relative "spec_helper"

# A UnitsML unit stem is inline OMML in every heading-like path (introduction
# subclause titles, preface titles, ToC entries) and in body text, never the
# raw unitsml(...) macro (metanorma-iso#1728; #1765 first kept it as text).
RSpec.describe IsoDoc::Iso::Docx::Adapter, "unit stems in heading-like paths" do
  let(:adapter) { build_adapter }
  let(:stem_xml) do
    '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">' \
      '<mrow><mn>80</mn><mo rspace="thickmathspace">⁢</mo>' \
      '<mrow xref="U_km"><mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow>' \
      '</mrow></math><asciimath>80 "unitsml(km)"</asciimath></stem>'
  end
  let(:rows) do
    convert_and_extract(adapter, minimal_iso_xml(body)) do |pkg|
      pkg.document.body.paragraphs.map do |p|
        { style: para_style_value(p), omaths: p.o_maths.length,
          text: p.runs.map { |r| run_text(r) }.join,
          xml: p.to_xml }
      end
    end
  end

  def row(style)
    rows.find { |r| r[:style] == style }
  end

  context "with an introduction subclause title" do
    let(:body) do
      <<~X
        <preface><introduction id="intro"><title>Introduction</title>
          <clause id="intro-1"><fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">0</semx>.<semx element="autonum">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">Alt #{stem_xml}</semx></fmt-title><p>Body #{stem_xml}</p></clause>
        </introduction></preface>
      X
    end

    it "renders the unit as OMML in the subclause title" do
      expect(row("a2")).to include(omaths: 1, text: "0.1Alt ")
    end

    it "keeps body paragraphs as OMML" do
      expect(rows.find { |r| r[:text] == "Body " }[:omaths]).to eq(1)
    end
  end

  context "with a foreword title" do
    let(:body) do
      <<~X
        <preface><foreword id="f"><fmt-title><semx element="title">Fore #{stem_xml}</semx></fmt-title><p>FB #{stem_xml}</p></foreword></preface>
      X
    end

    it "renders the unit as OMML in the foreword title" do
      expect(row("ForewordTitle")).to include(omaths: 1, text: "Fore ")
    end

    it "renders the unit as OMML in the ToC entry", :aggregate_failures do
      toc = row("TOC1")
      expect(toc[:omaths]).to eq(1)
      expect(toc[:xml].scan(%r{<w:t[^>]*>([^<]*)</w:t>}).join).to eq("Fore 1")
    end

    it "leaves no unitsml macro text in any paragraph" do
      expect(rows.map { |r| r[:xml] }).to all(satisfy { |x| !x.include?("unitsml(") })
    end

    it "keeps foreword body paragraphs as OMML" do
      expect(row("ForewordText")[:omaths]).to eq(1)
    end
  end
end
