# frozen_string_literal: true

require "spec_helper"
require "json"
require "tmpdir"

RSpec.describe Metanorma::Iso::Validation::PolicyDoc do
  let(:rule_registry) { Metanorma::Iso::Validation::RuleRegistry.new }
  let(:rules) { rule_registry.all }
  let(:legacy_policy) { Metanorma::Iso::Validation::LEGACY_POLICY }
  let(:entries) { described_class.policy_entries }
  let(:generated_at) { "2026-11-12T00:00:00Z" }
  let(:version) { Metanorma::Iso::VERSION }
  let(:adoc) do
    described_class.render_adoc(entries, version: version,
                                         generated_at: generated_at)
  end
  let(:json_text) do
    described_class.render_json(entries, version: version,
                                         generated_at: generated_at)
  end
  let(:json) { JSON.parse(json_text) }

  # Golden fixture: a frozen 3-entry sample (2 model rules, 1 legacy check)
  # pinned EXACTLY to guard the artifact format against drift.
  let(:golden_entries) do
    [
      {
        code: "STANDOC_48", rule_class: "ListCountRule", layer: "model",
        category: ["Lists"],
        rule: "avoid more than one numbered list in a clause/subclause",
        sources: ["house_style"], directives: nil, mn_category: "style",
        severity: 2
      },
      {
        code: "ISO_24", rule_class: "NormrefRule", layer: "model",
        category: ["Referencing > General"],
        rule: "the Normative references clause shall not be subdivided " \
              "into subclauses",
        sources: %w[house_style directives], directives: "15.4",
        mn_category: "references", severity: 2
      },
      {
        code: "STANDOC_48", rule_class: "list_punctuation", layer: "legacy",
        category: ["Punctuation > Lists"],
        rule: "every list is introduced by a sentence ending with a colon " \
              "or a full stop",
        sources: ["house_style"], directives: nil, mn_category: "style",
        severity: 2
      },
    ]
  end

  describe "JSON index schema" do
    it "carries the declared schema, flavour and gem version" do
      expect(json["schema"]).to eq(described_class::SCHEMA)
      expect(json["schema"]).to eq("metanorma-validation-policy/1")
      expect(json["flavor"]).to eq("iso")
      expect(json["gem_version"]).to eq(Metanorma::Iso::VERSION)
    end

    it "carries a parseable generation timestamp" do
      expect(Time.iso8601(json["generated_at"])).to be_a(Time)
    end

    it "has exactly the documented top-level keys" do
      expect(json.keys).to eq(
        %w[schema flavor gem_version generated_at rules],
      )
    end

    it "indexes every entry of both layers" do
      expect(json["rules"].size).to eq(rules.size + legacy_policy.size)
    end

    it "gives every entry exactly the documented keys" do
      json["rules"].each do |entry|
        expect(entry.keys).to eq(
          %w[code rule_class layer category rule sources directives
             mn_category severity],
        )
      end
    end

    it "gives every entry a non-empty code and identifier" do
      json["rules"].each do |entry|
        expect(entry["code"]).to be_a(String)
        expect(entry["code"]).not_to be_empty
        expect(entry["rule_class"]).to be_a(String)
        expect(entry["rule_class"]).not_to be_empty
      end
    end

    it "tags every entry with a known layer" do
      json["rules"].each do |entry|
        expect(%w[model legacy]).to include(entry["layer"])
      end
    end

    it "covers every concrete rule as a model-layer entry" do
      model_ids = json["rules"].select { |e| e["layer"] == "model" }
        .map { |e| e["rule_class"] }
      rules.each do |rule|
        short = rule.name.split("::").last
        expect(model_ids).to include(short)
      end
    end

    it "covers every legacy check as a legacy-layer entry" do
      legacy_ids = json["rules"].select { |e| e["layer"] == "legacy" }
        .map { |e| e["rule_class"] }
      expect(legacy_ids).to eq(legacy_policy.keys)
    end

    it "gives every entry an array of non-empty policy-category paths" do
      json["rules"].each do |entry|
        expect(entry["category"]).to be_an(Array)
        expect(entry["category"]).not_to be_empty
        entry["category"].each do |path|
          expect(path).to be_a(String)
          expect(path).not_to be_empty
        end
      end
    end

    it "gives every entry the cited rule wording" do
      json["rules"].each do |entry|
        expect(entry["rule"]).to be_a(String)
        expect(entry["rule"]).not_to be_empty
      end
    end

    it "restricts citation sources to the declared vocabulary" do
      json["rules"].each do |entry|
        expect(entry["sources"]).to be_an(Array)
        expect(entry["sources"]).not_to be_empty
        expect(entry["sources"] - described_class::CANONICAL_SOURCES.map(&:to_s))
          .to(eq([]))
      end
    end

    it "cites the Directives source whenever a clause is declared" do
      json["rules"].each do |entry|
        next unless entry["directives"]

        expect(entry["directives"]).to be_a(String)
        expect(entry["directives"]).not_to be_empty
        expect(entry["sources"]).to include("directives")
      end
    end

    it "gives every legacy entry citing the Directives its clause" do
      json["rules"].select { |e| e["layer"] == "legacy" }.each do |entry|
        next unless entry["sources"].include?("directives")

        expect(entry["directives"]).to be_a(String)
        expect(entry["directives"]).not_to be_empty
      end
    end

    it "restricts metanorma tags to the functional vocabulary" do
      json["rules"].each do |entry|
        expect(%w[style structure references]).to include(entry["mn_category"])
      end
    end

    it "carries a numeric or nil log severity on every entry" do
      json["rules"].each do |entry|
        expect(entry["severity"]).to(be_nil.or(be_an(Integer)))
      end
    end

    it "resolves severities from the log registries" do
      json["rules"].each do |entry|
        expect(entry["severity"]).to eq(described_class.severity_for(entry["code"]))
      end
    end

    it "keeps code+identifier pairs unique across entries" do
      ids = json["rules"].map { |e| [e["code"], e["rule_class"]] }
      expect(ids.uniq.size).to eq(ids.size)
    end

    it "keeps model rule identifiers unique" do
      model_ids = json["rules"].select { |e| e["layer"] == "model" }
        .map { |e| e["rule_class"] }
      expect(model_ids.uniq.size).to eq(model_ids.size)
    end
  end

  describe "ADOC page coverage" do
    it "titles the page and declares the generated gem version" do
      expect(adoc).to start_with("= Validation rules policy\n")
      expect(adoc).to include("metanorma-iso v#{version}")
    end

    it "renders every registry rule class as a table row" do
      rules.each do |rule|
        short = rule.name.split("::").last
        expect(adoc).to include("| #{short} |")
      end
    end

    it "renders every legacy check as a table row" do
      legacy_policy.each_key do |check|
        expect(adoc).to include("| #{check} |")
      end
    end

    it "renders the cited wording of every entry" do
      entries.each do |entry|
        expect(adoc).to include(entry[:rule])
      end
    end

    it "renders one row per category slot across entries" do
      # A rule spanning several policy categories appears in each of its
      # category sections.
      row_count = adoc.lines.count do |line|
        line.start_with?("| ") &&
          line.end_with?(" | model\n", " | legacy\n")
      end
      expect(row_count).to eq(entries.sum { |e| e[:category].size })
    end

    it "orders sections by the canonical House Style section order" do
      headings = adoc.lines.select { |l| l.start_with?("== ") }
      tops = headings.map { |h| h.sub("== ", "").chomp.split(" > ").first }
      known, unknown = tops.partition do |t|
        described_class::CANONICAL_SECTIONS.include?(t)
      end
      expect(unknown).to(eq([]),
                         "unrecorded top-level sections: #{unknown.uniq}")
      known_indices = known.map { |t| described_class::CANONICAL_SECTIONS.index(t) }
      expect(known_indices).to eq(known_indices.sort)
    end

    it "shows the citation sources separately per row" do
      expect(adoc).to include("ISO House Style")
      expect(adoc).to include("ISO/IEC DIR 2:2021 15.4")
    end
  end

  describe "golden fixture (format stability)" do
    it "renders the frozen sample ADOC exactly" do
      rendered = described_class.render_adoc(
        golden_entries, version: "3.5.11", generated_at: generated_at
      )
      expect(rendered).to eq(<<~GOLDEN)
        = Validation rules policy

        This page is the validation policy of the ISO flavour: every rule
        that the released metanorma-iso gem checks documents against, with
        the policy category it enforces, the citation that grounds it, and
        the metanorma functional tag that classifies it.

        Generated from metanorma-iso v3.5.11 on 2026-11-12T00:00:00Z:
        2 model-layer rules and
        1 legacy-layer check.

        The data on this page supports three filters: the ISO House Style
        policy-tree category (the section headings below), the metanorma
        functional tag (style, structure, references), and the citation
        source, which is named separately per row — rules sourced from the
        ISO House Style and rules restating the ISO/IEC Directives,
        Part 2:2021 are distinguishable. The machine-readable index
        alongside this page (validation-policy.json) carries the same records
        under schema metanorma-validation-policy/1.

        == Punctuation > Lists

        [cols="1,2,6,1,2,1,1",options="header"]
        |===
        | Code | Rule | Summary | Severity | Citations | metanorma tag | Layer

        | STANDOC_48 | list_punctuation | every list is introduced by a sentence ending with a colon or a full stop | error | ISO House Style | style | legacy
        |===

        == Lists

        [cols="1,2,6,1,2,1,1",options="header"]
        |===
        | Code | Rule | Summary | Severity | Citations | metanorma tag | Layer

        | STANDOC_48 | ListCountRule | avoid more than one numbered list in a clause/subclause | error | ISO House Style | style | model
        |===

        == Referencing > General

        [cols="1,2,6,1,2,1,1",options="header"]
        |===
        | Code | Rule | Summary | Severity | Citations | metanorma tag | Layer

        | ISO_24 | NormrefRule | the Normative references clause shall not be subdivided into subclauses | error | ISO House Style; ISO/IEC DIR 2:2021 15.4 | references | model
        |===
      GOLDEN
    end

    it "renders the frozen sample JSON exactly" do
      rendered = described_class.render_json(
        golden_entries, version: "3.5.11", generated_at: generated_at
      )
      expect(rendered).to eq(<<~GOLDEN)
        {
          "schema": "metanorma-validation-policy/1",
          "flavor": "iso",
          "gem_version": "3.5.11",
          "generated_at": "2026-11-12T00:00:00Z",
          "rules": [
            {
              "code": "STANDOC_48",
              "rule_class": "ListCountRule",
              "layer": "model",
              "category": [
                "Lists"
              ],
              "rule": "avoid more than one numbered list in a clause/subclause",
              "sources": [
                "house_style"
              ],
              "directives": null,
              "mn_category": "style",
              "severity": 2
            },
            {
              "code": "ISO_24",
              "rule_class": "NormrefRule",
              "layer": "model",
              "category": [
                "Referencing > General"
              ],
              "rule": "the Normative references clause shall not be subdivided into subclauses",
              "sources": [
                "house_style",
                "directives"
              ],
              "directives": "15.4",
              "mn_category": "references",
              "severity": 2
            },
            {
              "code": "STANDOC_48",
              "rule_class": "list_punctuation",
              "layer": "legacy",
              "category": [
                "Punctuation > Lists"
              ],
              "rule": "every list is introduced by a sentence ending with a colon or a full stop",
              "sources": [
                "house_style"
              ],
              "directives": null,
              "mn_category": "style",
              "severity": 2
            }
          ]
        }
      GOLDEN
    end
  end

  describe "generate with an output directory" do
    it "returns both artifact strings" do
      result = described_class.generate(version: "9.9.9",
                                        generated_at: generated_at)
      expect(result[:adoc])
        .to eq(described_class.render_adoc(entries, version: "9.9.9",
                                                    generated_at: generated_at))
      expect(result[:json])
        .to eq(described_class.render_json(entries, version: "9.9.9",
                                                    generated_at: generated_at))
    end

    it "writes both artifacts into the given directory" do
      Dir.mktmpdir do |dir|
        described_class.generate(output_dir: dir, version: "9.9.9",
                                 generated_at: generated_at)
        adoc_path = File.join(dir, described_class::ADOC_FILENAME)
        json_path = File.join(dir, described_class::JSON_FILENAME)
        expect(File.read(adoc_path)).to start_with("= Validation rules policy\n")
        expect(JSON.parse(File.read(json_path))["gem_version"]).to eq("9.9.9")
      end
    end
  end

  describe "severity_for" do
    it "resolves ISO codes from the ISO log registry" do
      expect(described_class.severity_for("ISO_24")).to eq(2)
    end

    it "resolves STANDOC codes from the standoc log registry" do
      expect(described_class.severity_for("STANDOC_48")).to eq(2)
    end

    it "returns nil for unknown codes" do
      expect(described_class.severity_for("ISO_9999")).to be_nil
    end
  end
end
