# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for vague time references (ISO House Style):
        # "last year", "recently", "lately" and "in the past" are
        # relative to the moment of reading, and publications outlive
        # that reference frame. State the actual date instead.
        class StyleVagueTimeRule < StyleRule
          VAGUE_TIME_REGEXES = {
            /\blast\s+year\b/i => "last year",
            /\brecently\b/i => "recently",
            /\blately\b/i => "lately",
            /\bin\s+the\s+past\b/i => "in the past"
          }.freeze

          def scan_text(node, text)
            findings = []
            VAGUE_TIME_REGEXES.each do |regex, phrase|
              findings.concat(
                finding_if_match(
                  node, text, regex,
                  "vague time reference '#{phrase}': state the actual " \
                  "date; publications outlive the reference frame"
                )
              )
            end
            findings
          end
        end
      end
    end
  end
end
