# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "relative standard deviation" and the
        # standalone acronym "RSD" (ISO House Style: use "coefficient of
        # variation" (Cv)).
        class StyleCvNotRsdRule < StyleRule
          RSD_REGEX = /\b(relative\ standard\ deviation)\b/xi.freeze
          RSD_ACRONYM_REGEX = /\b(RSD)\b/.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, RSD_REGEX,
              "style: '%s' (use 'coefficient of variation' (Cv))"
            ) + findings_for_matches(
              node, text, RSD_ACRONYM_REGEX,
              "style: '%s' (use 'coefficient of variation' (Cv))"
            )
          end
        end
      end
    end
  end
end
