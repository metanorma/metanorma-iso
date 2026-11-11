# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for amount-before-code order (ISO House Style):
        # the ISO 4217 alphabetic code precedes the amount, e.g.
        # "USD 100 million", not "100 USD" or "100 million dollars".
        #
        # The code list is the documented, conservative subset of
        # ISO 4217 codes in common use in standards text. Year-like
        # amounts ("in 2026 USD terms") are exempt: a four-digit 18xx/
        # 19xx/20xx number followed by a code is read as a year
        # qualifier, not an amount.
        class StyleCurrencyCodeOrderRule < StyleRule
          CURRENCY_CODES = %w[
            USD EUR GBP JPY CNY CHF CAD AUD NZD SEK NOK DKK INR KRW
            SGD HKD MXN BRL ZAR TRY PLN THB MYR IDR PHP AED SAR RUB
          ].freeze

          CODE_ORDER_REGEX =
            /\b(\d[\d.,]*)\s+(#{CURRENCY_CODES.join("|")})\b/.freeze

          YEAR_LIKE_AMOUNT_REGEX = /\A(?:18|19|20)\d{2}\z/.freeze

          LABEL = "amount-before-code order: the ISO 4217 code comes " \
                  "first — write '%1$s %2$s', not '%2$s %1$s'".freeze

          def scan_text(node, text)
            issues = []
            seen = []
            text.scan(CODE_ORDER_REGEX) do |amount, code|
              next if year_like_amount?(amount)

              key = "#{amount} #{code}"
              next if seen.include?(key)

              seen << key
              issues << build_warning(node, format(LABEL, code, amount))
            end
            issues
          end

          private

          def year_like_amount?(amount)
            amount.match?(YEAR_LIKE_AMOUNT_REGEX)
          end
        end
      end
    end
  end
end
