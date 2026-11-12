# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Validation rule policy metadata (issue #1709)" do
  # Policy sources ("ISO House Style", "ISO/IEC Directives Part 2:2021")
  # and the metanorma functional view, per the owner rulings on #1709.
  let(:valid_sources) { %i[house_style directives] }
  let(:valid_mn_categories) { %i[style structure references] }
  let(:rules) { Metanorma::Iso::Validation::RuleRegistry.new.all }

  it "discovers the concrete rule classes" do
    expect(rules).not_to be_empty
  end

  it "annotates every concrete rule with policy metadata" do
    uncited = rules.reject(&:policy_metadata)
    expect(uncited.map(&:name)).to(
      eq([]),
      "rules without policy metadata: #{uncited.map(&:name).join(', ')}",
    )
  end

  it "gives every concrete rule a policy-category path" do
    rules.each do |rule|
      meta = rule.policy_metadata
      paths = Array(meta[:category])
      expect(paths).not_to(be_empty, "#{rule}: missing policy category")
      paths.each do |path|
        expect(path).to be_a(String), "#{rule}: category is not a String: #{path.inspect}"
        expect(path).not_to be_empty, "#{rule}: empty policy category path"
      end
    end
  end

  it "gives every concrete rule a rule wording" do
    rules.each do |rule|
      wording = rule.policy_metadata[:rule]
      expect(wording).to be_a(String), "#{rule}: rule wording is not a String"
      expect(wording).not_to be_empty, "#{rule}: empty rule wording"
    end
  end

  it "gives every concrete rule a citation source" do
    rules.each do |rule|
      sources = Array(rule.policy_metadata[:source])
      expect(sources).not_to(be_empty, "#{rule}: missing citation source")
      invalid = sources - valid_sources
      expect(invalid).to(eq([]),
                         "#{rule}: unknown citation sources #{invalid.inspect}")
    end
  end

  it "gives every concrete rule a metanorma functional category" do
    rules.each do |rule|
      mn = rule.policy_metadata[:mn_category]
      expect(valid_mn_categories).to(include(mn),
                                     "#{rule}: unknown mn_category #{mn.inspect}")
    end
  end

  describe "DSL on Validation::Rules::Base" do
    before do
      stub_const("Metanorma::Iso::Validation::Rules::SpecPolicyRule",
                 Class.new(Metanorma::Iso::Validation::Rules::Base) do
                   code "ISO_TEST"
                 end)
    end

    let(:rule_class) do
      Metanorma::Iso::Validation::Rules::SpecPolicyRule
    end

    it "carries nil metadata until a declaration is made" do
      expect(rule_class.policy_metadata).to be_nil
    end

    it "accumulates the declared policy metadata" do
      rule_class.policy category: "Punctuation > Lists",
                        rule: "no more than one numbered list per clause",
                        source: :house_style, mn_category: :style

      expect(rule_class.policy_metadata).to eq(
        category: "Punctuation > Lists",
        rule: "no more than one numbered list per clause",
        source: :house_style, mn_category: :style
      )
    end

    it "widens a :house_style source when a Directives clause is declared" do
      rule_class.policy category: "Spelling and wording", rule: "r",
                        source: :house_style, mn_category: :style
      rule_class.directives "8.6"

      expect(rule_class.policy_metadata[:source])
        .to eq(%i[house_style directives])
      expect(rule_class.policy_metadata[:directives]).to eq("8.6")
    end

    it "accepts a both-sources declaration with the clause in one call" do
      rule_class.policy category: "Referencing", rule: "r",
                        source: %i[house_style directives],
                        directives: "10.5", mn_category: :references

      expect(rule_class.policy_metadata[:directives]).to eq("10.5")
    end

    it "is order-independent for the directives declaration" do
      rule_class.directives "12.4"
      rule_class.policy category: "Document structure", rule: "r",
                        source: :house_style, mn_category: :structure

      expect(rule_class.policy_metadata[:source])
        .to eq(%i[house_style directives])
    end

    it "does not leak declarations to sibling or parent classes" do
      rule_class.policy category: "Lists", rule: "r",
                        source: :house_style, mn_category: :style

      expect(Metanorma::Iso::Validation::Rules::Base.policy_metadata).to be_nil
      expect(Metanorma::Iso::Validation::Rules::StyleRule.policy_metadata).to be_nil
    end

    it "rejects unknown metadata keys" do
      expect { rule_class.policy(citation: "x") }
        .to raise_error(ArgumentError, /unknown policy metadata keys/)
    end

    it "rejects unknown citation sources" do
      expect do
        rule_class.policy(category: "Lists", rule: "r", source: :iso9000,
                          mn_category: :style)
      end.to raise_error(ArgumentError, /unknown policy sources/)
    end

    it "rejects unknown metanorma categories" do
      expect do
        rule_class.policy(category: "Lists", rule: "r", source: :house_style,
                          mn_category: :bibliography)
      end.to raise_error(ArgumentError, /unknown mn_category/)
    end
  end
end
