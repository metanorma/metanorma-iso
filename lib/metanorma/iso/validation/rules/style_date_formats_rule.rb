# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for date formats (ISO House Style):
        #
        #   - ordinal suffixes in dates are omitted: "31 October 2026",
        #     not "31st October 2026" or "the 3rd of October";
        #   - month-first (US) date order is not used: "October 31, 2026"
        #     becomes "31 October 2026" (day-month-year).
        class StyleDateFormatsRule < StyleRule
          policy category: "Numbers, values and dates > Dates",
                 rule: "write dates as '31 October 2026' (day month year, no ordinal suffixes)",
                 source: :house_style, mn_category: :style

          MONTH_NAMES = %w[
            January February March April May June July August September
            October November December
          ].freeze
          MONTH_ABBRS = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Sept Oct Nov Dec].freeze

          def self.month_alternative
            (MONTH_NAMES + MONTH_ABBRS).join("|")
          end

          # "31st October 2026", "the 3rd of October"
          DAY_FIRST_ORDINAL_REGEX = /
            \b\d{1,2}(?:st|nd|rd|th)\s+(?:of\s+)?(?:#{month_alternative})\b
          /ix.freeze

          # "March 3rd" (ordinal after a month name)
          MONTH_FIRST_ORDINAL_REGEX = /
            \b(?:#{month_alternative})\s+\d{1,2}(?:st|nd|rd|th)\b
          /ix.freeze

          # "October 31, 2026", "Oct 31 2026" — the ordinal-suffix-free
          # day guards against double-flagging ordinal dates.
          US_ORDER_REGEX = /
            \b(?:#{month_alternative})\.?\s+\d{1,2}(?![stndrdth])\s*,?\s+\d{4}\b
          /ix.freeze

          ORDINAL_LABEL = "ordinal date suffix: write '31 October 2026', not '%s'".freeze
          US_ORDER_LABEL = "month-first date order: write day-month-year, " \
                           "e.g. '31 October 2026', not '%s'".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, DAY_FIRST_ORDINAL_REGEX, ORDINAL_LABEL) +
              findings_for_matches(node, text, MONTH_FIRST_ORDINAL_REGEX, ORDINAL_LABEL) +
              findings_for_matches(node, text, US_ORDER_REGEX, US_ORDER_LABEL)
          end
        end
      end
    end
  end
end
