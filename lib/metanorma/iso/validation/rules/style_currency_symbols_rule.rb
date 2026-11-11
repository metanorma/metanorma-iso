# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for currency symbols in prose text (ISO House
        # Style): amounts are written with the ISO 4217 alphabetic
        # code, e.g. "USD 100", not "$100", "€100", "£100" or "¥100".
        #
        # Tables are governed by the same House Style point, but table
        # cell content is not prose and is walked by dedicated rules;
        # this rule flags prose paragraphs. Stem/formula content is
        # excluded by StyleRule#prose_exclusions, and sourcecode blocks
        # are excluded structurally.
        class StyleCurrencySymbolsRule < StyleRule
          CURRENCY_SYMBOL_REGEX = /[$€£¥]\s?\d/.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, CURRENCY_SYMBOL_REGEX,
              "currency symbol '%s' (use the ISO 4217 alphabetic code, " \
              "e.g. 'USD 100')"
            )
          end
        end
      end
    end
  end
end
