# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for "respectively" without a paired list (ISO
        # House Style): "respectively" maps the positions of two
        # enumerations onto each other, so the sentence must carry a
        # list ("A and B, respectively").
        #
        # Conservative: a sentence is flagged only when it contains
        # "respectively" and lacks BOTH a comma (a comma-list) and an
        # "and"/"or" enumeration. Sentences with either pass, and no
        # attempt is made to verify that the list positions actually
        # correspond.
        class StyleRespectivelyRule < StyleRule
          code "ISO_112"

          policy category: "Grammar",
                 rule: "'respectively' requires a paired enumeration " \
                       "in the same sentence ('A and B, respectively')",
                 source: :house_style, mn_category: :style

          RESPECTIVELY_REGEX = /\brespectively\b/i.freeze

          AND_OR_REGEX = /\b(?:and|or)\b/i.freeze

          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            Metanorma::Iso::Validation::SentenceScan.sentences(text)
              .filter_map do |sentence|
              next unless sentence.text.match?(RESPECTIVELY_REGEX)
              next if paired_list?(sentence.text)

              build_warning(
                node,
                "style: 'respectively' without a paired enumeration " \
                "in the sentence"
              )
            end
          end

          private

          # A comma-list or an "and"/"or" enumeration is present: the
          # sentence may legitimately carry "respectively".
          def paired_list?(sentence)
            sentence.include?(",") || sentence.match?(AND_OR_REGEX)
          end
        end
      end
    end
  end
end
