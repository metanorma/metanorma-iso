# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for informal interlaboratory terms (ISO House
        # Style: use "interlaboratory comparison", not "round robin" or
        # "ring test").
        class StyleInterlabRule < StyleRule
          policy category: "Spelling and wording > Interlaboratory or intralaboratory",
                 rule: "use 'interlaboratory comparison', not 'round robin' or 'ring test'",
                 source: :house_style, mn_category: :style

          INTERLAB_REGEX = /\b(round robins?|ring tests?)\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, INTERLAB_REGEX,
              "style: '%s' (use 'interlaboratory comparison')"
            )
          end
        end
      end
    end
  end
end
