require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::ComposedRegistry do
  let(:plain_registry) { Metanorma::Iso::Validation::RuleRegistry.new }

  def short_names(classes)
    classes.map { |c| c.name.split("::").last }
  end

  def rule_class(short_name)
    plain_registry.all.find { |c| c.name.split("::").last == short_name }
  end

  describe ".for" do
    it "carries exactly the plain registry when the flavor is nil" do
      composed = described_class.for(flavor: nil)
      expect(composed.all).to eq(plain_registry.all)
    end

    it "carries exactly the plain registry for iso (imports nothing)" do
      composed = described_class.for(flavor: "iso")
      expect(composed.all).to eq(plain_registry.all)
      composed.entries.each do |entry|
        expect(entry.severity).to be_nil
        expect(entry.cite_as).to be_nil
        expect(entry.source).to eq(:registry)
      end
    end

    it "carries exactly the plain registry for an uninstalled flavor" do
      composed = described_class.for(flavor: "no-such-flavor-xyz")
      expect(composed.all).to eq(plain_registry.all)
    end
  end

  describe ".compose" do
    it "composes profile imports" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "profile" => "oxford-spelling" }]
      )
      expect(short_names(composed.all)).to eq(%w[StyleOxfordSpellingRule])
    end

    it "composes class cherry-picks" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "class" => %w[StylePerCentRule ListCountRule] }]
      )
      expect(short_names(composed.all)).to contain_exactly("StylePerCentRule",
                                                           "ListCountRule")
    end

    it "raises on an import entry with neither profile nor class" do
      expect do
        described_class.compose(flavor: "specx", imports: [{ "except" => [] }])
      end.to raise_error(ArgumentError, /needs profile: or class:/)
    end

    it "raises on an unknown rule class in a class import" do
      expect do
        described_class.compose(flavor: "specx",
                                imports: [{ "class" => ["NoSuchRule"] }])
      end.to raise_error(ArgumentError, /unknown rule class/)
    end
  end

  describe "except resolution" do
    it "removes classes by stable class name" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "profile" => "lists",
                    "except" => ["ListPunctuationRule"] }]
      )
      expect(short_names(composed.all)).to contain_exactly(
        "ListCountRule", "ListDepthRule", "StyleMixedListsRule",
        "StylePenultimateListRule"
      )
    end

    it "removes every class carrying an excepted code" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "profile" => "directives", "except" => ["ISO_28"] }]
      )
      expect(composed.all).not_to include(rule_class("SectionSequenceRule"))
      expect(composed.all).to include(rule_class("ForewordStructureRule"))
    end

    it "raises on an unknown except token" do
      expect do
        described_class.compose(
          flavor: "specx",
          imports: [{ "profile" => "lists", "except" => ["NOPE_1"] }]
        )
      end.to raise_error(ArgumentError, /unknown except token/)
    end
  end

  describe "severity overrides" do
    it "carries a scalar override as entry metadata on the whole import" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "profile" => "oxford-spelling", "severity" => "warning" }]
      )
      expect(composed.severity_override_for(rule_class("StyleOxfordSpellingRule")))
        .to eq("warning")
    end

    it "carries a hash override per class name" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{
          "profile" => "lists",
          "severity" => { "ListCountRule" => "info" }
        }]
      )
      expect(composed.severity_override_for(rule_class("ListCountRule")))
        .to eq("info")
      expect(composed.severity_override_for(rule_class("ListDepthRule")))
        .to be_nil
    end

    it "does not leak overrides into other composed entries" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [
          { "profile" => "oxford-spelling", "severity" => "warning" },
          { "profile" => "referencing" }
        ]
      )
      expect(composed.severity_override_for(rule_class("BrokenXrefRule")))
        .to be_nil
    end
  end

  describe "flavor-attributed reporting (cite_as)" do
    it "carries the declared citation on imported entries" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [{ "profile" => "quality-english",
                    "cite_as" => "SPEC X editorial rules" }]
      )
      expect(composed.attribution_for(rule_class("StyleAOrAnRule")))
        .to eq("SPEC X editorial rules")
    end

    it "defaults the citation to the importing flavor's own policy name" do
      composed = described_class.compose(
        flavor: "bsi",
        imports: [{ "profile" => "quality-english" }]
      )
      expect(composed.attribution_for(rule_class("StyleContractionsRule")))
        .to eq("BSI style")
    end

    it "carries no citation for flavor-local and fallback entries" do
      fallback = described_class.compose(flavor: nil, imports: [])
      expect(fallback.attribution_for(rule_class("StyleOxfordSpellingRule")))
        .to be_nil
    end

    it "keeps separate citations per import entry" do
      composed = described_class.compose(
        flavor: "specx",
        imports: [
          { "profile" => "oxford-spelling", "cite_as" => "SPEC X spelling" },
          { "profile" => "lists" }
        ]
      )
      expect(composed.attribution_for(rule_class("StyleOxfordSpellingRule")))
        .to eq("SPEC X spelling")
      expect(composed.attribution_for(rule_class("ListCountRule")))
        .to eq("SPECX style")
    end
  end

  describe "flavor shadowing (registry precedence flavor > imported)" do
    before do
      namespace = Module.new
      validation = Module.new
      rules = Module.new
      stub_const("Metanorma::SpecShadow", namespace)
      stub_const("Metanorma::SpecShadow::Validation", validation)
      stub_const("Metanorma::SpecShadow::Validation::Rules", rules)
      stub_const("Metanorma::SpecShadow::Validation::Rules::ScopePresenceRule",
                 Class.new(Metanorma::Iso::Validation::Rules::Base) do
                   code "ISO_29"
                 end)
    end

    it "replaces the imported class with the flavor-local class of the same code" do
      composed = described_class.compose(
        flavor: "spec_shadow",
        imports: [{ "profile" => "directives" }]
      )
      expect(composed.all)
        .to include(Metanorma::SpecShadow::Validation::Rules::ScopePresenceRule)
      expect(composed.all).not_to include(rule_class("ScopePresenceRule"))
      expect(composed.origin_of(Metanorma::SpecShadow::Validation::Rules::ScopePresenceRule))
        .to eq(:flavor_local)
    end
  end

  describe "declaration schema" do
    it "rejects an unsupported declaration schema" do
      path = File.join(Dir.mktmpdir, "broken.yml")
      File.write(path, <<~YAML)
        schema: metanorma-validation-profile/999
        flavor: specx
        imports: []
      YAML
      expect do
        described_class.parse_declaration(path, "specx")
      end.to raise_error(ArgumentError, /unsupported declaration schema/)
    ensure
      File.delete(path)
    end

    it "rejects a declaration whose flavor does not match" do
      path = File.join(Dir.mktmpdir, "wrong-flavor.yml")
      File.write(path, <<~YAML)
        schema: metanorma-validation-profile/1
        flavor: other
        imports: []
      YAML
      expect do
        described_class.parse_declaration(path, "specx")
      end.to raise_error(ArgumentError, /declares flavor/)
    ensure
      File.delete(path)
    end
  end
end
