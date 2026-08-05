# frozen_string_literal: true

require_relative "spec_helper"

# TemplateProvenance: parses the YAML header produced by TemplateExtractor
# and verifies the reference DOCX's SHA-256 matches the recorded value.
#
# See TODO.new-dis/004-document-template-era-in-yaml.md.
RSpec.describe IsoDoc::Iso::Docx::TemplateProvenance do
  let(:data_dir) { File.expand_path("../../../data/iso-dis", __dir__) }
  let(:styles_path)        { File.join(data_dir, "styles.yml") }
  let(:numbering_path)     { File.join(data_dir, "numbering.yml") }
  let(:doc_defaults_path)  { File.join(data_dir, "doc_defaults.yml") }
  let(:style_mapping_path) { File.join(data_dir, "style_mapping.yml") }
  let(:fixture_path) do
    File.expand_path(
      "spec/fixtures/20250530-ISO_DIS_15926-100.docx",
      Dir.pwd,
    )
  end

  describe ".from_yaml" do
    it "parses styles.yml provenance header" do
      provenance = described_class.from_yaml(styles_path)
      expect(provenance).not_to be_nil
      expect(provenance.era).to eq("late_typefi")
      expect(provenance.reference_doc).to eq("20250530-ISO_DIS_15926-100.docx")
      expect(provenance.reference_doc_sha256).to match(/\A[0-9a-f]{64}\z/)
    end

    it "parses numbering.yml provenance header" do
      provenance = described_class.from_yaml(numbering_path)
      expect(provenance).not_to be_nil
      expect(provenance.era).to eq("late_typefi")
    end

    it "parses doc_defaults.yml provenance header" do
      provenance = described_class.from_yaml(doc_defaults_path)
      expect(provenance).not_to be_nil
      expect(provenance.era).to eq("late_typefi")
    end

    it "returns nil for a YAML without provenance header" do
      Tempfile.create(["noheader", ".yml"]) do |f|
        f.write("---\nfoo: bar\n")
        f.flush
        expect(described_class.from_yaml(f.path)).to be_nil
      end
    end
  end

  describe ".record_for" do
    it "computes the SHA-256 of the reference DOCX" do
      skip "DIS 15926 fixture not present" unless File.exist?(fixture_path)

      record = described_class.record_for(fixture_path)
      expected = Digest::SHA256.file(fixture_path).hexdigest
      expect(record.reference_doc_sha256).to eq(expected)
      expect(record.reference_doc).to eq("20250530-ISO_DIS_15926-100.docx")
      expect(record.era).to eq("late_typefi")
    end
  end

  describe "#matches_reference?" do
    it "returns true when the SHA matches the recorded value" do
      skip "DIS 15926 fixture not present" unless File.exist?(fixture_path)

      actual = Digest::SHA256.file(fixture_path).hexdigest
      provenance = described_class.from_yaml(styles_path)
      expect(provenance.matches_reference?(actual)).to be true
    end

    it "returns false when given a different SHA" do
      provenance = described_class.from_yaml(styles_path)
      expect(provenance.matches_reference?("0" * 64)).to be false
    end

    it "returns false when no SHA was recorded" do
      empty = described_class.new
      expect(empty.matches_reference?(Digest::SHA256.hexdigest("x"))).to be false
    end
  end

  describe "fixture integrity (CI gate)" do
    it "the recorded SHA-256 matches the current fixture bytes" do
      skip "DIS 15926 fixture not present" unless File.exist?(fixture_path)

      actual = Digest::SHA256.file(fixture_path).hexdigest
      [styles_path, numbering_path, doc_defaults_path].each do |path|
        provenance = described_class.from_yaml(path)
        expect(provenance.matches_reference?(actual)).to be(true),
          "#{File.basename(path)} records SHA " \
          "#{provenance.reference_doc_sha256[0, 8]}… but the fixture is " \
          "#{actual[0, 8]}… — re-run TemplateExtractor against the new fixture"
      end
    end
  end

  describe "#to_h" do
    it "returns a compact hash of provenance fields" do
      provenance = described_class.new(
        era: "late_typefi",
        reference_doc: "x.docx",
        reference_doc_sha256: "abc",
        extracted_at: "2026-06-18T00:00:00Z",
        extractor_version: nil,
      )
      expect(provenance.to_h).to eq(
        "template_era" => "late_typefi",
        "reference_doc" => "x.docx",
        "reference_doc_sha256" => "abc",
        "extracted_at" => "2026-06-18T00:00:00Z",
      )
    end
  end
end
