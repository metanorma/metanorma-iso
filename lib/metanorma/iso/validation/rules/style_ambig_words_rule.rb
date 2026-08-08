# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for ambiguous wording and common misspellings.
        # Subset of legacy validate_requirements.rb#ambig_words_check +
        # misspelled_words_check.
        #
        #   - "and/or" is forbidden (use "A or B or both").
        #   - "on-line", "cyber_security", "cyber-security" are misspellings.
        #   - "need to", "might", "could" are ambiguous modal verbs.
        #
        # Emitted via STANDOC_48 (generic style warning). Modal-verb-in-
        # clause context checks remain in legacy form (require clause-type
        # discrimination not yet ported).
        class StyleAmbigWordsRule < Base
          code "STANDOC_48"

          AND_OR_REGEX = /\band\/or\b/i.freeze
          MISSPELLED = {
            /\bon-line\b/i => "on-line (use 'online')",
            /\bcyber_security\b/i => "cyber_security (use 'cybersecurity')",
            /\bcyber-security\b/i => "cyber-security (use 'cybersecurity')"
          }.freeze
          AMBIG = {
            /\bneed\s+to\b/i => "need to (use 'shall' or 'should')",
            /\bmight\b/i => "might (ambiguous modal verb)",
            /\bcould\b/i => "could (ambiguous modal verb)"
          }.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_paragraph(context.root) do |paragraph, parent|
              text = extract_text(paragraph).strip
              next if text.empty?

              issues.concat(check_text(parent, text))
            end
            issues
          end

          private

          def check_text(node, text)
            findings = []
            findings.concat(check_pattern(node, text, AND_OR_REGEX, "and/or"))
            MISSPELLED.each do |regex, label|
              findings.concat(check_pattern(node, text, regex, label))
            end
            AMBIG.each do |regex, label|
              findings.concat(check_pattern(node, text, regex, label))
            end
            findings
          end

          def check_pattern(node, text, regex, label)
            return [] unless text.match?(regex)

            [build_issue(location: model_location(node),
                        params: ["style: #{label}"])]
          end
        end
      end
    end
  end
end
