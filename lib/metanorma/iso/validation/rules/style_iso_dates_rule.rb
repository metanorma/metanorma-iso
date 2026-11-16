# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: dates inside table (and figure) cells are
        # written in ISO format YYYY-MM-DD (ISO House Style). The
        # forms "31 October 2026", "October 31, 2026", "10/31/2026"
        # and "31.10.2026" are flagged inside table cells.
        #
        # Body prose is EXEMPT: "31 October 2026" is the correct prose
        # form (StyleDateFormatsRule governs prose dates — ordinals
        # and month-first order). Table cell content is not walked by
        # the paragraph-based style rules, so this rule is the only
        # checker that reaches it.
        class StyleIsoDatesRule < StyleRule
          code "ISO_99"

          policy category: "Numbers, values and dates > Dates",
                 rule: "use YYYY-MM-DD in table and figure cells",
                 source: :house_style, mn_category: :style

          def self.month_alternative
            StyleDateFormatsRule.month_alternative
          end

          # "31 October 2026", "31st October 2026"
          DAY_MONTH_YEAR_REGEX = /
            \b\d{1,2}(?:st|nd|rd|th)?\s+(?:#{month_alternative})\.?\s+\d{4}\b
          /ix.freeze

          # "October 31, 2026", "Oct. 31 2026"
          MONTH_DAY_YEAR_REGEX = /
            \b(?:#{month_alternative})\.?\s+\d{1,2}(?:st|nd|rd|th)?\s*,?\s+\d{4}\b
          /ix.freeze

          # "10/31/2026", "10/31/26" — slash-separated numeric order
          SLASH_DATE_REGEX = /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b/.freeze

          # "31.10.2026" — dotted numeric order. The 4-digit year is
          # required so software version strings ("1.2.10") are not
          # mistaken for dates.
          DOT_DATE_REGEX = /\b\d{1,2}\.\d{1,2}\.\d{4}\b/.freeze

          LABEL = "table date format: use YYYY-MM-DD in tables, not '%s'".freeze

          def check(context)
            issues = []
            each_instance_of(
              context.root, Metanorma::Document::Components::Tables::TableCell
            ) do |cell|
              text = extract_text(cell).strip
              next if text.empty?

              issues.concat(findings_for_matches(cell, text, DAY_MONTH_YEAR_REGEX, LABEL))
              issues.concat(findings_for_matches(cell, text, MONTH_DAY_YEAR_REGEX, LABEL))
              issues.concat(findings_for_matches(cell, text, SLASH_DATE_REGEX, LABEL))
              issues.concat(findings_for_matches(cell, text, DOT_DATE_REGEX, LABEL))
            end
            issues
          end
        end
      end
    end
  end
end
