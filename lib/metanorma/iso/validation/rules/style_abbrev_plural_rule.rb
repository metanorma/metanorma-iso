# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: abbreviated terms are invariant — they are not
        # pluralized by appending "s". This rule deliberately stays
        # narrow: it flags only the doubled-s form "MSSs" (the plural
        # of the abbreviated term "MSS" written as "MSSs"). Broader
        # abbreviated-term pluralization is a high-false-positive
        # context-sensitive check and is out of scope here.
        class StyleAbbrevPluralRule < StyleRule
          policy category: "Abbreviated terms",
                 rule: "abbreviated terms are invariant — do not pluralize by appending 's'",
                 source: :house_style, mn_category: :style

          # Case-sensitive: the doubled-s plural form of "MSS".
          MSSS_REGEX = /\bMSSs\b/.freeze

          def scan_text(node, text)
            finding_if_match(
              node, text, MSSS_REGEX,
              "style: 'MSSs' (abbreviated terms are invariant — 'MSS' " \
              "is not pluralized)"
            )
          end
        end
      end
    end
  end
end
