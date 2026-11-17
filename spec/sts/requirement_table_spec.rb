# frozen_string_literal: true

require_relative "spec_helper"

# Requirement / recommendation / permission blocks → STS formal tables
# (<table-wrap>), matching the HTML/PDF rendering:
# - PREFERRED: the <fmt-provision> table from the sibling presentation
#   XML mapped 1:1 (label, fmt-name caption, bold header cells,
#   mnconvert content-type vocabulary, specific-use="modspec");
# - FALLBACK: rows synthesized from the semantic components
#   (Description / Statement / Measurement target / Verification /
#   Inheritance / Imported + Classification) per the renderer's
#   REQ_COMPONENTS inventory; nested tests render after the parent.
RSpec.describe Metanorma::Iso::Sts::Transformer::RequirementTransformer do
  let(:semantic_xml) do
    <<~XML
      <metanorma>
        <bibdata>
          <title language="en" type="main">T</title>
          <docidentifier>ISO 1:2025</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1">
            <title>Req</title>
            <requirement id="_a1" anchor="rc-1" model="ogc" type="class">
              <title>Class one</title>
              <identifier>/req/one</identifier>
              <description id="_d1"><p id="_p1">Desc text.</p></description>
              <specification id="_s1"><ol id="_o1"><li><p id="_p3">Step one.</p></li></ol></specification>
              <inherit id="_i1">/req/base</inherit>
              <classification><tag>target-type</tag><value>register</value></classification>
              <requirement id="_a2" anchor="r-2" model="ogc" type="verification">
                <identifier>/req/one/t1</identifier>
                <description id="_d2"><p id="_p2">Test text.</p></description>
              </requirement>
            </requirement>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:presentation_xml) do
    <<~XML
      <metanorma>
        <bibdata>
          <title language="en" type="main">T</title>
          <docidentifier>ISO 1:2025</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1">
            <title>Req</title>
            <requirement id="_pa1" anchor="rc-1" model="ogc" type="class" autonum="1">
              <title>Class one</title>
              <fmt-provision id="_fp1">
                <table id="rc-1-t" type="recommendclass" class="modspec" autonum="5">
                  <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">Table</span> 5</span><span class="fmt-caption-delim"> &#8212; </span>Requirements class 1: Class one</fmt-name>
                  <tbody>
                    <tr><th>Identifier</th><td><tt>/req/one</tt></td></tr>
                    <tr><th>Description</th><td><p id="_pp1">Desc rendered.</p></td></tr>
                  </tbody>
                </table>
              </fmt-provision>
              <requirement id="_pa2" anchor="r-2" model="ogc" type="verification">
                <identifier>/req/one/t1</identifier>
              </requirement>
            </requirement>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  def convert_with_presentation(xml, presentation)
    root = Metanorma::Iso::Document::Root.from_xml(xml)
    adapter = Metanorma::Iso::Sts::Transformer::Standard.new(
      root, { sts_presentation_xml: presentation }
    )
    adapter.transform.to_xml
  end

  def wraps(doc)
    doc.xpath("//body//table-wrap")
  end

  describe "provision path (sibling presentation XML)" do
    let(:doc) { Nokogiri::XML(convert_with_presentation(semantic_xml, presentation_xml)) }

    it "maps the provision table 1:1 as the parent's table-wrap" do
      wrap = wraps(doc).first
      expect(wrap["id"]).to eq("rc-1")
      expect(wrap["content-type"]).to eq("recommendclass")
      expect(wrap["specific-use"]).to eq("modspec")
      expect(wrap.at("./label").text.strip).to eq("Table\u00A05")
      expect(wrap.at("./caption/title").text.strip.tr("\u00A0", " ")).to eq("Table 5 — Requirements class 1: Class one")
    end

    it "carries the provision rows with bold headers" do
      wrap = wraps(doc).first
      ths = wrap.xpath("./table/tbody/tr/th")
      expect(ths.map(&:text).map(&:strip)).to eq(%w[Identifier Description])
      expect(ths.first.at("./bold")).not_to be_nil
      expect(wrap.at("./table/tbody/tr[1]/td/monospace").text).to eq("/req/one")
      expect(wrap.at("./table/tbody/tr[2]/td").text).to include("Desc rendered.")
    end

    it "renders the nested test after the parent table" do
      ids = wraps(doc).map { |w| w["id"] }
      expect(ids.first).to eq("rc-1")
      expect(ids).to include("r-2")
    end

    it "keeps the tables XSD-valid" do
      output = convert_with_presentation(semantic_xml, presentation_xml)
      expect(output).to include("<table-wrap")
    end
  end

  describe "fallback path (no presentation XML)" do
    let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(semantic_xml)) }

    it "synthesizes one table-wrap per requirement, nested tests after the parent" do
      ids = wraps(doc).map { |w| w["id"] }
      expect(ids).to eq(%w[rc-1 r-2])
      expect(wraps(doc).first["content-type"]).to eq("recommendclass")
      expect(wraps(doc).last["content-type"]).to eq("recommendtest")
      expect(wraps(doc).last["specific-use"]).to eq("modspec")
    end

    it "labels the table from the requirement type vocabulary" do
      expect(wraps(doc).first.at("./label").text).to eq("Requirements class /req/one")
      expect(wraps(doc).last.at("./label").text).to eq("Requirement test /req/one/t1")
    end

    it "carries the requirement title as the caption" do
      expect(wraps(doc).first.at("./caption/title").text).to eq("Class one")
    end

    it "synthesizes a row per populated component with bold row labels" do
      labels = wraps(doc).first.xpath("./table/tbody/tr/th/bold").map(&:text)
      expect(labels).to eq(%w[Description Statement Inheritance Classification])
    end

    it "carries description paragraphs, specification lists, and monospace inheritance" do
      wrap = wraps(doc).first
      expect(wrap.at("./table/tbody/tr[1]/td/p").text).to eq("Desc text.")
      expect(wrap.at("./table/tbody/tr[2]/td/list[@list-type='arabic']")).not_to be_nil
      expect(wrap.at("./table/tbody/tr[3]/td/monospace").text).to eq("/req/base")
      expect(wrap.at("./table/tbody/tr[4]/td").text).to eq("target-type register")
    end
  end
end
