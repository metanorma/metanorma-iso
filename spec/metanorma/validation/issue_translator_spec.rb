require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::IssueTranslator do
  # Real Log — minimal stub of Metanorma::Utils::Log API. We do not use
  # double() (per project rules); this Struct implements the surface the
  # translator depends on (#add with keyword params).
  FakeLog = Struct.new(:entries) do
    def initialize
      super([])
    end

    def add(code, loc, params: [])
      entries << { code: code, location: loc, params: params }
    end
  end

  let(:log) { FakeLog.new }
  let(:report) { Metanorma::Iso::Validation::Report.new(document: "x") }
  let(:translator) { described_class.new(log: log, report: report) }

  describe "#translate_layer3" do
    it "routes Issues to both @log and Report without re-interpolation" do
      issue = Metanorma::Iso::Validation::Issue.from_finding(
        code: "ISO_5", location: nil, params: ["pizza"]
      )
      translator.translate_layer3([issue])

      expect(log.entries.size).to eq(1)
      expect(log.entries.first[:code]).to eq("ISO_5")
      expect(log.entries.first[:params]).to eq(["pizza"]) # raw params, not pre-formatted
      expect(report.issues.size).to eq(1)
      expect(report.issues.first.code).to eq("ISO_5")
      expect(report.issues.first.message).to eq("pizza is not a recognised document type")
    end

    it "is a no-op for empty issues" do
      translator.translate_layer3([])
      expect(log.entries).to be_empty
      expect(report.issues).to be_empty
    end
  end

  describe "#translate_layer1" do
    it "translates RequiredAttributeMissingError to STANDOC_7" do
      # Build a real Layer 1 error via a Serializable that fails validation.
      breaking_class = Class.new(Lutaml::Model::Serializable) do
        attribute :name, :string, required: true
      end
      instance = breaking_class.new(name: nil)
      errors = instance.validate

      translator.translate_layer1(errors)

      expect(log.entries.size).to eq(errors.size)
      expect(report.issues.size).to eq(errors.size)
      expect(log.entries.first[:code]).to eq("STANDOC_7")
    end
  end

  describe "with log: nil" do
    let(:translator) { described_class.new(log: nil, report: report) }

    it "skips @log but still populates Report" do
      issue = Metanorma::Iso::Validation::Issue.from_finding(
        code: "ISO_5", location: nil, params: ["pizza"]
      )
      translator.translate_layer3([issue])
      expect(report.issues.size).to eq(1)
    end
  end
end
