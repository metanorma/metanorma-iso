# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for number formatting in text content. Covers a
        # subset of the legacy validate_numeric.rb checks:
        #
        #   - Decimal points: numbers containing "." should be marked up
        #     with stem:[] (ISO/IEC DIR 2, 9.1).
        #   - Hyphen instead of minus sign (U+2212).
        #
        # Subscript depth remains in legacy form pending TODO 33 SubElement
        # extension (the model currently drops nested <sub> children).
        class StyleNumberRule < StyleRule
          DECIMAL_POINT_REGEX = /(?:^|\p{Zs})([0-9]+\.[0-9]+)(?!\.[0-9])/i.freeze
          HYPHEN_MINUS_REGEX = /(?:^|\p{Zs})(-[0-9][0-9,.]*)/i.freeze

          # Flavors whose structure rules govern decimal conventions
          # themselves (metanorma-bsi's 27.x euro-annex regimes) own this
          # concern; the ISO-generic scan would double-report and contradict
          # the flavor's own verdicts.
          DECIMAL_POINT_FLAVOR_OWNERS = %w(bsi).freeze

          def check(context)
            @validation_flavor = context.state&.flavor
            super
          end

          def scan_text(node, text)
            decimal = flavor_owns_decimal? ? [] : findings_for_matches(
              node, text, DECIMAL_POINT_REGEX,
              "possible decimal point: mark up numbers with stem:[]: %s",
            )
            decimal + findings_for_matches(node, text, HYPHEN_MINUS_REGEX,
                                           "hyphen instead of minus sign U+2212: %s")
          end

          def flavor_owns_decimal?
            DECIMAL_POINT_FLAVOR_OWNERS.include?(@validation_flavor)
          end
        end
      end
    end
  end
end
