# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "percent" as one word (ISO House Style: use
        # "per cent" as two words, or "percentage"). The "%" symbol is
        # not flagged: symbol usage is governed by the unit-spacing rules
        # (StyleUnitsRule).
        class StylePerCentRule < StyleRule
          policy category: "Numbers, values and dates > Numbers",
                 rule: "use 'per cent' (two words) in text, not 'percent'",
                 source: :house_style, mn_category: :style

          PERCENT_WORD_REGEX = /\b(percent)\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, PERCENT_WORD_REGEX,
              "style: 'percent' (use 'per cent' as two words, or 'percentage')"
            )
          end
        end
      end
    end
  end
end
