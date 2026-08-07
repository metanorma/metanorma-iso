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
    it "routes Lutaml Issues to both @log and Report" do
      issue = Lutaml::Model::Validation::Issue.new(
        severity: "error", code: "ISO_5",
        message: "pizza is not a recognised document type",
        location: nil
      )
      translator.translate_layer3([issue])

      expect(log.entries.size).to eq(1)
      expect(log.entries.first[:code]).to eq("ISO_5")
      expect(report.issues.size).to eq(1)
      expect(report.issues.first.code).to eq("ISO_5")
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
      issue = Lutaml::Model::Validation::Issue.new(
        severity: "error", code: "ISO_5", message: "x", location: nil
      )
      translator.translate_layer3([issue])
      expect(report.issues.size).to eq(1)
    end
  end
end
