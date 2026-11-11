# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for "formulas" (ISO House Style: the plural of
        # "formula" is "formulae" for all mathematical forms).
        # The singular "formula" is correct and is not flagged.
        class StyleFormulaeRule < StyleRule
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
