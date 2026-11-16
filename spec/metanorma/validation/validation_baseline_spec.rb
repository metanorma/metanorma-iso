# frozen_string_literal: true

require "spec_helper"
require "yaml"

# The shipped flavour validation baseline
# (lib/metanorma/iso/validation_policy/metanorma.yml): the flavour layer of
# the declarative suppression resolution chain
# (metanorma/metanorma-standoc#1369). v1 is TYPE-ONLY: the only per-rule
# action is +severity+. The standoc suppression Config class is parsed by
# the engine; this spec pins the shipped data by shape and coverage
# directly, so it stays green independently of that work.
RSpec.describe "the ISO flavour validation baseline" do
  subject(:baseline) { YAML.safe_load(File.read(baseline_path)) }

  let(:baseline_path) do
    File.expand_path(
      "../../../lib/metanorma/iso/validation_policy/metanorma.yml", __dir__
    )
  end

  let(:policy_doc) { Metanorma::Iso::Validation::PolicyDoc }
  let(:flavor_codes) do
    policy_doc.policy_entries.map { |entry| entry[:code] }.uniq
  end

  describe "document shape (metanorma-validation-suppression/1, type-only)" do
    it "declares exactly the schema, flavour and rules keys" do
      expect(baseline.keys).to eq(%w[schema flavor rules])
    end

    it "declares the frozen suppression-config schema string" do
      expect(baseline["schema"]).to eq("metanorma-validation-suppression/1")
      expect(baseline["schema"]).to eq(policy_doc::BASELINE_SCHEMA)
    end

    it "declares the iso flavour" do
      expect(baseline["flavor"]).to eq("iso")
    end

    it "maps rule codes to severity entries" do
      expect(baseline["rules"]).to be_a(Hash)
      expect(baseline["rules"]).not_to be_empty
    end

    it "carries log-code-shaped keys" do
      baseline["rules"].each_key do |code|
        expect(code).to match(/\A[A-Z]+_\d+\z/)
      end
    end

    it "gives every entry exactly one severity action" do
      baseline["rules"].each_value do |entry|
        expect(entry).to be_a(Hash)
        expect(entry.keys).to eq(%w[severity])
      end
    end

    it "restricts severities to the v1 action vocabulary" do
      baseline["rules"].each_value do |entry|
        expect(policy_doc::BASELINE_ACTIONS).to include(entry["severity"])
      end
    end

    it "suppresses nothing by default: no entry is severity off" do
      expect(baseline["rules"].values.map { |e| e["severity"] })
        .not_to include("off")
    end
  end

  describe "regeneration gate" do
    it "ships exactly what PolicyDoc.baseline_yaml generates" do
      expect(File.read(baseline_path)).to eq(policy_doc.baseline_yaml)
    end

    it "documents the registry default in the file header" do
      header = File.read(baseline_path).lines
        .take_while { |line| line.start_with?("#") }.join
      expect(header).to include(policy_doc::BASELINE_SCHEMA)
      expect(header).to include("severity: #{policy_doc::BASELINE_DEFAULT_SEVERITY}")
    end
  end

  describe "code coverage (bidirectional)" do
    it "has an entry for every code the flavour emits" do
      expect(baseline["rules"].keys).to include(*flavor_codes)
    end

    it "has no entry for a code the flavour does not emit" do
      unknown = baseline["rules"].keys - flavor_codes
      expect(unknown).to eq([])
    end

    it "orders entries in the canonical policy order" do
      expect(baseline["rules"].keys).to eq(policy_doc.baseline_rules.keys)
    end
  end

  describe "severities" do
    it "sits every code at its natural registry severity" do
      baseline["rules"].each do |code, entry|
        expect(entry["severity"]).to eq(policy_doc.baseline_severity(code))
      end
    end

    it "resolves every shipped code from the log registries" do
      unresolved = flavor_codes.select do |code|
        policy_doc.severity_for(code).nil?
      end
      expect(unresolved).to eq([])
    end
  end

  describe "baseline_severity fallback" do
    it "takes the registry default for a code neither registry knows" do
      expect(policy_doc.baseline_severity("ISO_9999"))
        .to eq(policy_doc::BASELINE_DEFAULT_SEVERITY)
      expect(policy_doc.baseline_severity("ISO_9999")).to eq("error")
    end
  end
end
