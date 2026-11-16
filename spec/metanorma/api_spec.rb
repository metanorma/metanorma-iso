require "spec_helper"
require "json"
require "yaml"

RSpec.describe Metanorma::Iso::API do
  describe ".validate" do
    let(:minimal_xml) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
          </bibdata>
          <preface>
            <foreword id="fw"><p>foreword text</p></foreword>
          </preface>
          <sections>
            <clause type="scope" id="scope"><title>Scope</title></clause>
            <terms id="terms"><title>Terms</title></terms>
            <clause id="c1"><title>Body</title></clause>
          </sections>
          <bibliography>
            <references normative="true"><title>Norm Refs</title></references>
            <references normative="false"><title>Bibliography</title></references>
          </bibliography>
        </metanorma>
      XML
    end

    it "returns a Report" do
      report = described_class.validate(minimal_xml)
      expect(report).to be_a(Metanorma::Iso::Validation::Report)
    end

    it "accepts converter-state keywords" do
      report = described_class.validate(
        minimal_xml,
        lang: "fr", script: "Latn", doctype: "international-standard",
        vocab: false, amd: false, document: "spec.xml"
      )
      expect(report.document).to eq("spec.xml")
    end

    it "captures findings for invalid input" do
      bad_xml = minimal_xml.sub(
        '<docidentifier>ISO 1</docidentifier>',
        '<docidentifier>ISO 1</docidentifier>'
      )
      # Add a subclause as only-child to trigger ISO_43
      bad_xml = bad_xml.sub(
        '<clause id="c1"><title>Body</title></clause>',
        '<clause id="c1"><title>Body</title><clause id="c2"><title>lone</title></clause></clause>'
      )
      report = described_class.validate(bad_xml)
      expect(report.errors.map(&:code)).to include("ISO_43")
    end
  end

  describe ".render" do
    let(:report) { described_class.validate("") }

    it "renders text format via Reporter::Text" do
      output = described_class.render(report, format: :text)
      expect(output).to be_a(String)
      expect(output).to end_with("\n")
    end

    it "renders json format via report.to_json" do
      output = described_class.render(report, format: :json)
      parsed = JSON.parse(output)
      expect(parsed).to be_a(Hash)
    end

    it "renders yaml format via report.to_yaml" do
      output = described_class.render(report, format: :yaml)
      parsed = YAML.safe_load(output)
      expect(parsed).to be_a(Hash)
    end

    it "returns the report unchanged for :report format" do
      expect(described_class.render(report, format: :report)).to be(report)
    end

    it "raises ArgumentError for unknown formats" do
      expect { described_class.render(report, format: :nope) }
        .to raise_error(ArgumentError)
    end
  end
end
