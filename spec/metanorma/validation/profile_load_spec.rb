require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Profile do
  let(:registry) { Metanorma::Iso::Validation::RuleRegistry.new }

  def short_names(classes)
    classes.map { |c| c.name.split("::").last }
  end

  def metadata_of(short_name)
    registry.all.find { |c| c.name.split("::").last == short_name }
      .policy_metadata
  end

  describe ".load" do
    it "raises on an unknown profile" do
      expect { described_class.load("no-such-profile") }
        .to raise_error(ArgumentError, /unknown validation profile/)
    end

    it "loads every published profile with the declared schema" do
      %w[house-style directives quality-english house-style-core
         lists referencing oxford-spelling].each do |name|
        profile = described_class.load(name)
        expect(profile.name).to eq(name)
        expect(profile.flavor).to eq(:iso)
        expect(profile.path).to end_with("#{name}.yml")
      end
    end

    it "rejects an unsupported schema version" do
      dir = Metanorma::Iso::Validation::Profile::PROFILES_DIR
      path = File.join(dir, "bogus-schema.yml")
      begin
        File.write(path, <<~YAML)
          schema: metanorma-validation-profile/999
          profile: bogus-schema
          flavor: iso
          select: []
        YAML
        expect { described_class.load("bogus-schema") }
          .to raise_error(ArgumentError, /unsupported profile schema/)
      ensure
        File.delete(path)
      end
    end
  end

  describe "published family profiles (source-first, issue #1720)" do
    it "house-style selects exactly the rules citing the House Style" do
      selected = described_class.load("house-style").select(registry)
      expected = registry.all.select do |cls|
        Array(cls.policy_metadata[:source]).include?(:house_style)
      end
      expect(selected).to match_array(expected)
    end

    it "directives selects exactly the rules citing the Directives" do
      selected = described_class.load("directives").select(registry)
      expected = registry.all.select do |cls|
        Array(cls.policy_metadata[:source]).include?(:directives)
      end
      expect(selected).to match_array(expected)
    end

    it "dual-source rules appear in both families" do
      dual = %w[ModalInClauseRule StyleInclusiveLanguageRule
                StyleNumberRule StyleUnitsRule]
      dual.each do |name|
        meta = metadata_of(name)
        expect(Array(meta[:source])).to contain_exactly(:house_style,
                                                        :directives)
        expect(described_class.load("house-style").select(registry))
          .to include(registry.all.find { |c| c.name.end_with?(name) })
        expect(described_class.load("directives").select(registry))
          .to include(registry.all.find { |c| c.name.end_with?(name) })
      end
    end

    it "keeps the families independent" do
      house = described_class.load("house-style").select(registry)
      directives = described_class.load("directives").select(registry)
      # DoctypeRule is Directives-only; StyleOxfordSpellingRule is
      # House-Style-only.
      doctype = registry.all.find { |c| c.name.end_with?("DoctypeRule") }
      oxford = registry.all.find { |c| c.name.end_with?("StyleOxfordSpellingRule") }
      expect(house).not_to include(doctype)
      expect(directives).to include(doctype)
      expect(house).to include(oxford)
      expect(directives).not_to include(oxford)
    end
  end

  describe "published sub-profiles within the house-style family" do
    it "lists selects exactly the list rules" do
      selected = described_class.load("lists").select(registry)
      expect(short_names(selected)).to contain_exactly(
        "ListCountRule", "ListDepthRule", "ListPunctuationRule",
        "StyleMixedListsRule", "StylePenultimateListRule"
      )
    end

    it "oxford-spelling selects the spelling rule by policy category" do
      selected = described_class.load("oxford-spelling").select(registry)
      expect(short_names(selected)).to eq(%w[StyleOxfordSpellingRule])
    end

    it "referencing selects the House Style referencing rules" do
      selected = described_class.load("referencing").select(registry)
      selected.each do |cls|
        meta = cls.policy_metadata
        expect(meta[:mn_category]).to eq(:references)
        expect(Array(meta[:source])).to include(:house_style)
        expect(Array(meta[:source])).not_to include(:directives)
      end
      expect(short_names(selected)).to contain_exactly(
        "AssetCitedFirstRule", "BrokenXrefRule", "StyleDirectivesRefsRule",
        "StyleImpreciseRefsRule", "StyleInformativeNormativeRule",
        "StyleSelfReferenceRule", "StyleWikipediaRule",
        "TermSourceCompleteRule", "TermXrefsRule", "UniqueIdRule"
      )
    end

    it "house-style-core is the style slice of the house-style family" do
      core = described_class.load("house-style-core").select(registry)
      family = described_class.load("house-style").select(registry)
      lists = described_class.load("lists").select(registry)
      expect(core - family).to be_empty
      expect(lists - core).to be_empty
      core.each do |cls|
        expect(cls.policy_metadata[:mn_category]).to eq(:style)
      end
      expect(short_names(core)).to include("StyleOxfordSpellingRule",
                                           "StylePerCentRule")
      expect(short_names(core)).not_to include("DoctypeRule",
                                               "NormativeBibitemRule")
    end
  end

  describe "the general tier (quality-english)" do
    it "selects its curated flavor-neutral classes by name" do
      selected = described_class.load("quality-english").select(registry)
      expect(short_names(selected)).to contain_exactly(
        "StyleOxfordSpellingRule", "StyleContractionsRule", "StyleAOrAnRule",
        "StyleAffectEffectRule", "StyleAssureEnsureRule", "StyleFewerLessRule",
        "StyleThatWhichRule", "StyleApostrophePluralsRule"
      )
    end
  end

  describe "selector semantics" do
    it "conjoins keys within an entry and disjoins across entries" do
      profile = described_class::Published.new(
        name: "synthetic",
        selectors: [
          { "mn_category" => "structure", "source" => "house_style" },
          { "mn_category" => "style", "source" => "directives" }
        ]
      )
      selected = profile.select(registry)
      # Structure ∧ House Style = the house-style structural rules;
      # Style ∧ Directives = TermdefStyleRule plus the four dual-source
      # style rules that also cite the House Style.
      expect(short_names(selected)).to contain_exactly(
        "StyleEmptyClauseRule", "SymbolsInAnnexRule", "VocabTermsTitlesRule",
        "TermdefStyleRule", "ModalInClauseRule", "StyleInclusiveLanguageRule",
        "StyleNumberRule", "StyleUnitsRule"
      )
    end

    it "supports explicit class entries alongside metadata selectors" do
      profile = described_class::Published.new(
        name: "synthetic",
        selectors: [
          { "mn_category" => "references", "source" => "house_style" },
          { "class" => ["StylePerCentRule"] }
        ]
      )
      selected = profile.select(registry)
      expect(short_names(selected)).to include("StylePerCentRule",
                                               "BrokenXrefRule")
    end

    it "raises on an unknown class name in a class entry" do
      profile = described_class::Published.new(
        name: "synthetic",
        selectors: [{ "class" => ["NoSuchRuleClass"] }]
      )
      expect { profile.select(registry) }
        .to raise_error(ArgumentError, /unknown rule class/)
    end

    it "matches nothing via selectors when a rule declares no metadata" do
      rule = Class.new(Metanorma::Iso::Validation::Rules::Base) do
        code "ISO_TEST_NO_META"
      end
      allow(registry).to receive(:all).and_return([rule])
      profile = described_class::Published.new(
        name: "synthetic", selectors: [{ "source" => "house_style" }]
      )
      expect(profile.select(registry)).to be_empty
    end
  end

  describe "published profiles as runtime profiles" do
    it "filters rule instances to the selected classes" do
      profile = described_class.load("oxford-spelling")
      oxford = registry.all.find { |c| c.name.end_with?("StyleOxfordSpellingRule") }
      doctype = registry.all.find { |c| c.name.end_with?("DoctypeRule") }
      instances = [oxford.new, doctype.new]
      expect(profile.select_rules(instances).map(&:class)).to eq([oxford])
    end
  end
end
