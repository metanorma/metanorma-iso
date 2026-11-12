# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for country names that ISO House Style requires
        # in their full or official form:
        #
        #   - "North Korea" -> the Democratic People's Republic of Korea
        #     (DPRK)
        #   - "South Korea" -> the Republic of Korea (ROK)
        #   - "Russia" -> the Russian Federation
        #   - "Vietnam" -> Viet Nam
        #
        # The short forms "UK" and "US" are permitted exceptions and are
        # deliberately not flagged.
        class StyleCountryNamesRule < StyleRule
          policy category: "Spelling and wording > Names of countries, territories and currencies",
                 rule: "use the official country names (DPRK, ROK, the Russian Federation, Viet Nam)",
                 source: :house_style, mn_category: :style

          COUNTRY_NAMES = {
            /\bnorth korea\b/i =>
              "style: 'North Korea' (use 'the Democratic People's " \
              "Republic of Korea (DPRK)')",
            /\bsouth korea\b/i =>
              "style: 'South Korea' (use 'the Republic of Korea (ROK)')",
            /\brussia\b/i =>
              "style: 'Russia' (use 'the Russian Federation')",
            /\bvietnam\b/i =>
              "style: 'Vietnam' (use 'Viet Nam')"
          }.freeze

          def scan_text(node, text)
            COUNTRY_NAMES.filter_map do |regex, label|
              next unless text.match?(regex)

              build_warning(node, label)
            end
          end
        end
      end
    end
  end
end
