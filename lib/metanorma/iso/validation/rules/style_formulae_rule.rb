# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for "formulas" (ISO House Style: the plural of
        # "formula" is "formulae" for all mathematical forms).
        # The singular "formula" is correct and is not flagged.
        class StyleFormulaeRule < StyleRule
          code "ISO_91"

          policy category: "Spelling and wording > Formula(e)",
                 rule: "use 'formulae' (plural) for all mathematical forms",
                 source: :house_style, mn_category: :style

          FORMULAS_REGEX = /\bformulas\b/i.freeze

          def scan_text(node, text)
            finding_if_match(
              node, text, FORMULAS_REGEX,
              "style: 'formulas' (House Style: use 'formulae' for all " \
              "mathematical forms)"
            )
          end
        end
      end
    end
  end
end
