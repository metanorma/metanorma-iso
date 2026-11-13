require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Profile do
  let(:rule_stub) do
    Struct.new(:code).new("ISO_TEST")
  end

  describe "DEFAULT" do
    it "runs all rules" do
      rules = [rule_stub, Struct.new(:code).new("STANDOC_48")]
      expect(described_class::DEFAULT.select_rules(rules).size).to eq(2)
    end

    it "does not treat warnings as fatal" do
      expect(described_class::DEFAULT.strict_warnings).to be(false)
    end
  end

  describe "STRICT" do
    it "treats warnings as fatal" do
      expect(described_class::STRICT.strict_warnings).to be(true)
    end
  end

  describe "PUBLICATION" do
    it "excludes the flavour style codes and the standoc style sink" do
      style_code = Metanorma::Iso::Validation::Rules::StyleAOrAnRule.code_value
      expect(style_code).to include("ISO_")
      expect(described_class::PUBLICATION.except_codes)
        .to include(style_code, "STANDOC_48")
      rules = [Struct.new(:code).new("ISO_5"),
               Struct.new(:code).new(style_code),
               Struct.new(:code).new("STANDOC_48")]
      selected = described_class::PUBLICATION.select_rules(rules)
      expect(selected.map(&:code)).to eq(["ISO_5"])
    end

    it "covers every StyleRule descendant and style-lint class" do
      suppressed = described_class::PUBLICATION.except_codes
      rules = Metanorma::Iso::Validation::RuleRegistry.new.all
        .select do |cls|
          cls < Metanorma::Iso::Validation::Rules::StyleRule ||
            described_class::STYLE_LINT_CLASSES.include?(cls.name.split("::").last)
        end
      expect(rules.map(&:code_value) - suppressed).to eq([])
    end
  end

  describe "custom profile" do
    it "filters to only specified codes" do
      profile = described_class.new(name: "ci", only_codes: ["ISO_5", "ISO_29"])
      rules = [Struct.new(:code).new("ISO_5"), Struct.new(:code).new("ISO_42"),
               Struct.new(:code).new("ISO_29")]
      selected = profile.select_rules(rules)
      expect(selected.map(&:code)).to contain_exactly("ISO_5", "ISO_29")
    end

    it "excludes specified codes" do
      profile = described_class.new(name: "no-style", except_codes: ["STANDOC_48"])
      rules = [Struct.new(:code).new("ISO_5"), Struct.new(:code).new("STANDOC_48")]
      selected = profile.select_rules(rules)
      expect(selected.map(&:code)).to eq(["ISO_5"])
    end
  end

  describe "#fatal_findings?" do
    it "returns false for DEFAULT with only warnings" do
      warning_report = Metanorma::Iso::Validation::Report.new.tap do |r|
        # ISO_21 is severity 1 (warning)
        r.add_issue(code: "ISO_21", location: nil, params: %w[annex A])
      end
      expect(described_class::DEFAULT.fatal_findings?(warning_report)).to be(false)
    end

    it "returns true for STRICT with warnings" do
      warning_report = Metanorma::Iso::Validation::Report.new.tap do |r|
        r.add_issue(code: "ISO_21", location: nil, params: %w[annex A])
      end
      expect(described_class::STRICT.fatal_findings?(warning_report)).to be(true)
    end
  end
end

RSpec.describe Metanorma::Iso::API do
  describe ".validate with profile" do
    let(:xml) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        </metanorma>
      XML
    end

    it "accepts :default symbol" do
      expect { described_class.validate(xml, profile: :default) }.not_to raise_error
    end

    it "accepts :publication symbol (no style warnings)" do
      report = described_class.validate(xml, profile: :publication)
      suppressed = Metanorma::Iso::Validation::Profile::PUBLICATION.except_codes
      expect(report.issues.none? { |i| suppressed.include?(i.code) }).to be(true)
    end

    it "accepts a Profile instance" do
      profile = Metanorma::Iso::Validation::Profile.new(name: "only-doctype",
                                                        only_codes: ["ISO_5"])
      report = described_class.validate(
        "<metanorma xmlns=\"https://www.metanorma.org/ns/standoc\"/>",
        doctype: "pizza", profile: profile
      )
      expect(report.issues.map(&:code).uniq).to contain_exactly("ISO_5")
    end

    it "raises for unknown symbol" do
      expect { described_class.validate(xml, profile: :nope) }
        .to raise_error(ArgumentError)
    end
  end
end
