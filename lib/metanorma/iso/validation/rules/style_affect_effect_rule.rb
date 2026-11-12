# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "affect"/"effect" confusion (ISO House
        # Style): "affect" is the verb of influence ("X affects Y"),
        # "effect" is the noun ("the effect of X on Y").
        #
        # The pattern list below is deliberately closed: only the
        # clearly-wrong forms are flagged, and unknown contexts pass.
        #
        #   - "effect(s) the result/performance/value/measurement" —
        #     "effect" used as a verb of influence (use "affects");
        #   - "a/the/an affect" — "affect" used as a noun (use
        #     "effect").
        #
        # The legitimate verbal use "to effect changes" (bring about)
        # and noun phrases like "side effects" are not matched.
        class StyleAffectEffectRule < StyleRule
          policy category: "Grammar",
                 rule: "use 'affect' as the verb of influence and 'effect' " \
                       "as the noun ('X affects Y', 'the effect of X on Y')",
                 source: :house_style, mn_category: :style

          EFFECT_AS_VERB_REGEX =
            /\beffects?\s+the\s+(?:result|performance|value|measurement)\b/i.freeze

          AFFECT_AS_NOUN_REGEX = /\b(?:the|a|an)\s+affects?\b/i.freeze

          # Strip the duplicated json_* text copies so each paragraph
          # contributes its prose exactly once.
          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            findings_for_matches(
              node, text, EFFECT_AS_VERB_REGEX,
              "style: '%s' (use 'affects': 'affect' is the verb of influence)"
            ) + findings_for_matches(
              node, text, AFFECT_AS_NOUN_REGEX,
              "style: '%s' (use 'effect': 'effect' is the noun)"
            )
          end
        end
      end
    end
  end
end
