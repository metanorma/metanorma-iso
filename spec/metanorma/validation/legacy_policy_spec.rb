# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Iso::Validation::LEGACY_POLICY" do
  subject(:policy) { Metanorma::Iso::Validation::LEGACY_POLICY }

  let(:gem_root) { File.expand_path("../../..", __dir__) }

  # The legacy layer is the Nokogiri-era LegacyChecks module in
  # lib/metanorma/iso/validate.rb. When a future legacy file appears, it is
  # added here so the scan below keeps covering the whole layer.
  let(:legacy_sources) do
    %w[lib/metanorma/iso/validate.rb].map { |rel| File.join(gem_root, rel) }
  end

  # Static scan: every literal log code the legacy layer can emit — both
  # direct @log.add(...) calls and the code: literals passed to the
  # style_warning sink (indirect emitters like style_regex and
  # style_two_regex_not_prev route through it).
  let(:legacy_codes) do
    legacy_sources.flat_map do |path|
      File.readlines(path).filter_map do |line|
        line[/@log\.add\(\s*["']([A-Z]+_\d+)["']/, 1] ||
          line[/code:\s*["']([A-Z]+_\d+)["']/, 1]
      end
    end.uniq.sort
  end

  let(:policy_codes) { policy.values.map { |e| e[:code] }.uniq.sort }

  it "finds a non-empty set of codes in the legacy source" do
    expect(legacy_codes).not_to be_empty
  end

  it "covers every log code the legacy layer emits" do
    expect(legacy_codes - policy_codes).to be_empty
  end

  it "carries no stale entries for codes the legacy layer no longer emits" do
    expect(policy_codes - legacy_codes).to be_empty
  end

  it "keys each entry by its LegacyChecks check method name" do
    policy.each_key do |method|
      expect(method).to match(/\A[a-z_][a-z0-9_]*\z/)
    end
  end

  it "is frozen" do
    expect(policy).to be_frozen
  end

  it "gives every entry a code, category, rule, source and mn_category" do
    policy.each do |method, entry|
      %i[code category rule source mn_category].each do |field|
        expect(entry).to have_key(field),
          "legacy check #{method} lacks #{field}"
        expect(entry[field]).not_to be_nil,
          "legacy check #{method} has nil #{field}"
      end
    end
  end

  it "restricts mn_category to the metanorma functional tags" do
    policy.each do |method, entry|
      expect(%i[style structure references])
        .to include(entry[:mn_category]),
            "legacy check #{method} has invalid mn_category " \
            "#{entry[:mn_category]}"
    end
  end

  it "restricts source citations to house_style and directives" do
    policy.each do |method, entry|
      expect(entry[:source]).to be_a(Array)
      expect(entry[:source]).not_to be_empty
      entry[:source].each do |src|
        expect(%i[house_style directives]).to include(src),
          "legacy check #{method} cites unknown source #{src}"
      end
    end
  end

  it "cites a House Style section for every :house_style source" do
    policy.each do |method, entry|
      next unless entry[:source].include?(:house_style)

      expect(entry[:section]).to be_a(String),
        "legacy check #{method} cites :house_style without a section"
      expect(entry[:section]).not_to be_empty
    end
  end

  it "carries a DIR 2 clause number for every :directives source" do
    policy.each do |method, entry|
      next unless entry[:source].include?(:directives)

      expect(entry[:directives]).to match(/\A[\d., ]+\z/),
        "legacy check #{method} cites :directives without a clause number"
    end
  end

  it "roots every category path in the ISO House Style 2026-08 tree" do
    top_level = [
      "Relationship with the ISO/IEC Directives, Parts 1 and 2",
      "Plain language", "Tone", "Grammar", "Spelling and wording",
      "Abbreviated terms, abbreviations and contractions", "Punctuation",
      "Numbers, values and dates", "Symbols", "Referencing", "Formatting",
    ]
    policy.each do |method, entry|
      root = entry[:category].split(" > ").first
      expect(top_level).to include(root),
        "legacy check #{method} has category #{entry[:category].inspect} " \
        "outside the House Style tree"
    end
  end
end
