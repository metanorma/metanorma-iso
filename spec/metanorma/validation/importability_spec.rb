require "spec_helper"

RSpec.describe "rule importability (issue #1720)" do
  # Importable rule classes must not reach into metanorma-iso flavor
  # internals: when another flavor imports a rule, only the shared
  # document model and the infrastructure the rules ship with travel
  # with them. The static scan below walks every rule class file and
  # asserts the Metanorma::Iso:: references stay inside the boundary.
  #
  # The boundary (enumerated, not zero — some ISO-namespace references
  # are legitimate):
  #   - Metanorma::Iso::Document::* : the shared semantic model. Every
  #     flavor validates THROUGH this model (flavor validators inherit
  #     Metanorma::Iso::Validate, whose model_validate deserializes into
  #     Metanorma::Iso::Document::Root), so model types are the seam, not
  #     a violation.
  #   - Metanorma::Iso::Converter::ISO_LOG_MESSAGES : the code → message
  #     table, referenced from Rules::Base only. It ships in the same gem
  #     as the rules, so an importer always has it.
  RULES_DIR = File.expand_path("../../../lib/metanorma/iso/validation/rules",
                               __dir__)
  # Metanorma::Iso::Validation::* is the validation infrastructure the
  # rules run through (Issue, SentenceScan, Rules::Base) — part of the
  # seam, never a violation.
  INFRA_PREFIX = "Metanorma::Iso::Validation".freeze
  ALLOWED_ROOTS = ["Metanorma::Iso::Document"].freeze
  ALLOWED_EXACT = ["Metanorma::Iso::Converter::ISO_LOG_MESSAGES"].freeze

  def scan_references(path)
    File.readlines(path).reject { |line| line.lstrip.start_with?("#") }
        .join
        .scan(/Metanorma::Iso::[A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*/)
        .uniq
        .reject { |ref| ref.start_with?("#{INFRA_PREFIX}::") ||
                       ref == INFRA_PREFIX }
  end

  it "every rule file stays inside the enumerated ISO-namespace boundary" do
    violations = []
    Dir[File.join(RULES_DIR, "*.rb")].sort.each do |path|
      scan_references(path).each do |ref|
        next if ALLOWED_ROOTS.any? { |root| ref.start_with?("#{root}::") }
        next if ALLOWED_EXACT.include?(ref)

        violations << "#{File.basename(path)}: #{ref}"
      end
    end
    expect(violations).to be_empty,
                          "flavor-namespace references outside the " \
                          "importability boundary:\n#{violations.join("\n")}"
  end

  it "the boundary is exercised (guards against a vacuous scan)" do
    raw_base_refs = File.readlines(File.join(RULES_DIR, "base.rb"))
      .join.scan(/Metanorma::Iso::[A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*/)
      .uniq
    expect(raw_base_refs).to include("Metanorma::Iso::Validation::Issue",
                                     "Metanorma::Iso::Converter::ISO_LOG_MESSAGES")
    model_users = Dir[File.join(RULES_DIR, "*.rb")]
      .select { |p| scan_references(p).any? { |r| r.start_with?("Metanorma::Iso::Document::") } }
    expect(model_users).not_to be_empty
  end

  it "every concrete rule carries policy metadata (import documentation gate)" do
    missing = Metanorma::Iso::Validation::RuleRegistry.new.all
      .reject(&:policy_metadata)
      .map { |c| c.name.split("::").last }
    expect(missing).to be_empty
  end
end
