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
        class StyleAmbigWordsRule < StyleRule
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

          def scan_text(node, text)
            findings = []
            findings.concat(finding_if_match(node, text, AND_OR_REGEX, "style: and/or"))
            MISSPELLED.each do |regex, label|
              findings.concat(finding_if_match(node, text, regex, "style: #{label}"))
            end
            AMBIG.each do |regex, label|
              findings.concat(finding_if_match(node, text, regex, "style: #{label}"))
            end
            findings
          end
        end
      end
    end
  end
end
