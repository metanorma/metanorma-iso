# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for date/number ranges (ISO House Style):
        # the connective "to" is written out where the closed-up hyphen
        # or en dash would be read as a minus sign.
        #
        #   - "10-15 March" becomes "10 to 15 March";
        #   - "2020-2030" becomes "2020 to 2030";
        #   - "the 18th-19th centuries" becomes "the 18th to 19th centuries";
        #   - centuries are spelled out in words: "the twentieth century",
        #     not "the 20th century".
        #
        # Closed-up page ranges ("pp. 45-49") remain permitted under the
        # en dash rule: only spans whose two sides look like dates, years
        # or centuries are flagged.
        class StyleDateDurationRule < StyleRule
          code "ISO_82"

          policy category: "Numbers, values and dates > Dates",
                 rule: "write date durations with 'to' ('10 to 15 March', '2020 to 2030'); spell centuries out in words",
                 source: :house_style, mn_category: :style

          def self.month_alternative
            StyleDateFormatsRule.month_alternative
          end

          # "10-15 March" (hyphen or en dash)
          DAY_RANGE_MONTH_REGEX = /
            \b\d{1,2}\s*[-–]\s*\d{1,2}\s+(?:#{month_alternative})\b
          /ix.freeze

          # "2020-2030", "2020–2030" — both sides four-digit years
          YEAR_RANGE_REGEX = /\b\d{4}\s*[-–]\s*\d{4}\b/.freeze

          # "the 18th-19th centuries"
          CENTURY_RANGE_REGEX = /
            \b\d{1,2}(?:st|nd|rd|th)\s*[-–]\s*\d{1,2}(?:st|nd|rd|th)\s+centur
          /ix.freeze

          # "the 20th century" — centuries are spelled out in words
          DIGIT_CENTURY_REGEX = /
            \bthe\s+\d{1,2}(?:st|nd|rd|th)\s+centur
          /ix.freeze

          DAY_RANGE_LABEL = "date range: use 'to', e.g. '10 to 15 March', not '%s'".freeze
          YEAR_RANGE_LABEL = "year range: use 'to', e.g. '2020 to 2030', not '%s'".freeze
          CENTURY_RANGE_LABEL = "century range: use 'to', e.g. " \
                                "'the 18th to 19th centuries', not '%s'".freeze
          DIGIT_CENTURY_LABEL = "century in words: write 'the twentieth century', " \
                                "not '%s century'".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, DAY_RANGE_MONTH_REGEX, DAY_RANGE_LABEL) +
              findings_for_matches(node, text, YEAR_RANGE_REGEX, YEAR_RANGE_LABEL) +
              findings_for_matches(node, text, CENTURY_RANGE_REGEX, CENTURY_RANGE_LABEL) +
              findings_for_matches(node, text, DIGIT_CENTURY_REGEX, DIGIT_CENTURY_LABEL)
          end
        end
      end
    end
  end
end
