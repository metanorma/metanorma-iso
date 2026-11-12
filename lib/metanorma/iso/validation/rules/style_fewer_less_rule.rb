# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "less"/"fewer" confusion (ISO House
        # Style): countable nouns take "fewer" ("fewer samples"),
        # uncountables take "less" ("less time", "less equipment").
        #
        # The count-noun list is deliberately closed: only frequent
        # sample/test nouns are flagged. "Less than 10 min" (quantity
        # with a unit) and uncountables pass because their heads are
        # not on the list. A negative lookahead keeps "less than N
        # <count noun>" ("less than 10 samples") on the "fewer than"
        # pattern instead of double-flagging it.
        class StyleFewerLessRule < StyleRule
          code "ISO_90"

          policy category: "Grammar",
                 rule: "use 'fewer' for countable nouns ('fewer samples'); " \
                       "'less' is for uncountables ('less time') and " \
                       "'less than' with quantities ('less than 10 min')",
                 source: :house_style, mn_category: :style

          COUNT_NOUNS = %w[
            samples specimens tests trials results measurements readings
            errors items products documents examples cases steps
            parameters variables requirements clauses subclauses figures
            tables references notes terms definitions symbols units
            components elements parts batches votes people
          ].freeze

          NOUNS_GROUP = COUNT_NOUNS.join("|").freeze

          LESS_COUNT_REGEX = /\bless\s+(?!than\b)(?:#{NOUNS_GROUP})\b/i.freeze

          LESS_THAN_COUNT_REGEX =
            /\bless\s+than\s+\d+\s+(?:#{NOUNS_GROUP})\b/i.freeze

          # Strip the duplicated json_* text copies so each paragraph
          # contributes its prose exactly once.
          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            findings_for_matches(
              node, text, LESS_COUNT_REGEX,
              "style: '%s' (use 'fewer' with countable nouns)"
            ) + findings_for_matches(
              node, text, LESS_THAN_COUNT_REGEX,
              "style: '%s' (use 'fewer than' with countable nouns)"
            )
          end
        end
      end
    end
  end
end
