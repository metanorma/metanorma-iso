require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Report do
  let(:report) { described_class.new(document: "rice.adoc") }

  it "starts valid with no issues" do
    expect(report).to be_valid
    expect(report.issues).to be_empty
    expect(report.errors).to be_empty
  end

  describe "#add_issue" do
    it "appends an issue built from a finding" do
      report.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
      expect(report.issues.size).to eq(1)
      expect(report.errors.size).to eq(1)
      expect(report).not_to be_valid
    end

    it "preserves valid status when only warnings are added" do
      report.add_issue(code: "ISO_21", location: "annex A", params: %w[annex A])
      expect(report.warnings.size).to eq(1)
      expect(report.errors).to be_empty
      expect(report).to be_valid
    end
  end

  describe "#summary" do
    it "includes the document and finding counts" do
      report.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
      report.add_issue(code: "ISO_21", location: "annex", params: %w[annex A])
      summary = report.summary
      expect(summary).to include("rice.adoc")
      expect(summary).to include("2 findings")
      expect(summary).to include("1 errors")
      expect(summary).to include("1 warnings")
    end
  end

  describe "serialization" do
    it "round-trips through JSON with all issues" do
      report.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
      json = report.to_json
      parsed = described_class.from_json(json)
      expect(parsed.issues.size).to eq(1)
      expect(parsed.issues.first.code).to eq("ISO_5")
    end
  end
end
