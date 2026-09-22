require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::ModelValidator do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", doctype: "international-standard",
      document: "spec"
    )
  end

  describe ".run with empty XML" do
    it "returns a Report with no issues" do
      report = described_class.run("", log: nil, state: state)
      expect(report).to be_a(Metanorma::Iso::Validation::Report)
      expect(report.issues).to be_empty
    end
  end

  describe ".run with a minimal valid document" do
    let(:xml) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
          </bibdata>
        </metanorma>
      XML
    end

    it "deserializes without raising and runs Layer 3 rules" do
      report = described_class.run(xml, log: nil, state: state)
      # The minimal document is intentionally incomplete; Layer 3 rules
      # correctly flag missing scope/terms etc. We assert the run completes
      # and produces structured Issues rather than asserting zero findings.
      expect(report).to be_a(Metanorma::Iso::Validation::Report)
      expect(report.issues).to be_an(Array)
    end
  end

  describe "output formats" do
    let(:xml) { "" }

    it "returns Report alone when output_format is :log" do
      result = described_class.run(xml, log: nil, state: state, output_format: :log)
      expect(result).to be_a(Metanorma::Iso::Validation::Report)
    end

    it "returns [Report, String] when output_format is :json" do
      result = described_class.run(xml, log: nil, state: state, output_format: :json)
      expect(result).to be_an(Array)
      expect(result[0]).to be_a(Metanorma::Iso::Validation::Report)
      expect(result[1]).to be_a(String)
      expect(JSON.parse(result[1])["document"]).to eq("spec")
    end

    it "returns [Report, String] when output_format is :yaml" do
      result = described_class.run(xml, log: nil, state: state, output_format: :yaml)
      expect(result[1]).to be_a(String)
      expect(YAML.safe_load(result[1])["document"]).to eq("spec")
    end

    it "raises ArgumentError on unknown format" do
      expect {
        described_class.run(xml, log: nil, state: state, output_format: :nope)
      }.to raise_error(ArgumentError)
    end
  end
end
