# frozen_string_literal: true

require "unitsdb"

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for currency symbols in prose text (ISO House
        # Style): amounts are written with the ISO 4217 alphabetic
        # code, e.g. "USD 100", not "€100", "£100" or "¥100".
        #
        # The symbol set is Unitsdb's: the symbol presentations recorded
        # for ISO 4217 currencies ("€", "£", "¥", "US$", "A$", ...).
        # Currencies without a recorded symbol presentation flag nothing
        # here — in particular Unitsdb records no bare "$" for USD — so
        # the ISO 4217 CODE rules below cover the code-first policy.
        #
        # Tables are governed by the same House Style point, but table
        # cell content is not prose and is walked by dedicated rules;
        # this rule flags prose paragraphs. Stem/formula content is
        # excluded by StyleRule#prose_exclusions, and sourcecode blocks
        # are excluded structurally.
        class StyleCurrencySymbolsRule < StyleRule
          code "ISO_80"

          policy category: "Spelling and wording > Names of countries, territories and currencies",
                 rule: "use ISO 4217 codes rather than currency symbols",
                 source: :house_style, mn_category: :style

          # Unitsdb-derived symbol set, built once per process at rule
          # autoload: the Unitsdb database load happens here, never per
          # scanned paragraph.
          CURRENCY_SYMBOLS = Unitsdb.database.currencies.flat_map do |currency|
            (currency.symbols || []).map(&:unicode)
          end.compact.uniq.freeze

          CURRENCY_SYMBOL_REGEX =
            /(#{CURRENCY_SYMBOLS.sort_by(&:length).reverse
              .map { |symbol| Regexp.escape(symbol) }.join('|')})\s?\d/.freeze

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
