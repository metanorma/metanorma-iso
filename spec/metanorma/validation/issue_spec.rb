require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Issue do
  describe ".from_finding" do
    it "looks up severity/category/message template from ISO_LOG_MESSAGES" do
      issue = described_class.from_finding(code: "ISO_5", location: nil,
                                          params: ["pizza"])
      expect(issue.code).to eq("ISO_5")
      expect(issue.severity).to eq("error") # ISO_5 severity is 2
      expect(issue.category).to eq("Document Attributes")
      expect(issue.message).to eq("pizza is not a recognised document type")
      expect(issue.params).to eq(["pizza"])
    end

    it "maps ISO_21 (severity 1) to warning" do
      issue = described_class.from_finding(code: "ISO_21",
                                           location: "annex", params: %w[annex A])
      expect(issue.severity).to eq("warning")
      expect(issue.location).to eq("annex")
    end

    it "uses Unknown/default spec when code is not registered" do
      issue = described_class.from_finding(code: "ISO_UNKNOWN",
                                           location: nil, params: ["foo"])
      expect(issue.category).to eq("Unknown")
      expect(issue.severity).to eq("error")
    end

    it "handles empty params without interpolation" do
      issue = described_class.from_finding(code: "ISO_8", location: nil)
      expect(issue.message).to eq("Reference does not have an associated footnote indicating unpublished status")
    end
  end

  describe "#error?/#warning?/#info?" do
    it "returns true for matching severity" do
      expect(described_class.new(severity: "error", code: "X", message: "m")).to be_error
      expect(described_class.new(severity: "warning", code: "X", message: "m")).to be_warning
      expect(described_class.new(severity: "info", code: "X", message: "m")).to be_info
    end
  end

  describe "serialization" do
    it "round-trips through JSON" do
      issue = described_class.from_finding(code: "ISO_5", location: nil,
                                          params: ["pizza"])
      json = issue.to_json
      parsed = described_class.from_json(json)
      expect(parsed.code).to eq("ISO_5")
      expect(parsed.severity).to eq("error")
      expect(parsed.message).to eq("pizza is not a recognised document type")
    end
  end
end
