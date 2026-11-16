# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for wrong indefinite articles before words
        # whose SOUND contradicts their spelling (ISO House Style):
        # "an hour" (silent h), "a European" (consonant "y" sound),
        # "a user", "a university", "a one-hour test".
        #
        # Both directions are closed exception lists covering WORDS
        # only. Initialisms pronounced letter-wise ("an ISO standard")
        # are out of scope here: StyleAbbrevArticlesRule covers them,
        # so this rule skips initialisms entirely to avoid
        # double-flagging.
        class StyleAOrAnRule < StyleRule
          code "ISO_62"

          policy category: "Grammar > A or an",
                 rule: "use 'an' before a vowel sound ('an hour') and 'a' " \
                       "before a consonant sound ('a European', 'a user')",
                 source: :house_style, mn_category: :style

          # Words with an initial vowel SOUND: they take "an" despite
          # the consonant spelling (silent letters).
          A_BEFORE_VOWEL_SOUND_REGEX =
            /\ba\s+(?:hour(?:ly)?|honest(?:ly)?|honesty|hono(?:u)?r(?:ed)?|heir)\b/i.freeze

          # Words with an initial consonant SOUND (typically an initial
          # "y" glide): they take "a" despite the vowel spelling.
          AN_BEFORE_CONSONANT_SOUND_REGEX =
            %r{\ban\s+(?:europeans?|one(?:[-—][a-z]+)?|users?|useful(?:ness)?|utilisation|utilization|unique|universities|university|union|united|uniform|uniformity|units?|eula)}i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, A_BEFORE_VOWEL_SOUND_REGEX,
              "wrong article '%s' (use 'an' before a vowel sound)"
            ) + findings_for_matches(
              node, text, AN_BEFORE_CONSONANT_SOUND_REGEX,
              "wrong article '%s' (use 'a' before a consonant sound)"
            )
          end

          # Strip the duplicated json_* text copies so each paragraph
          # contributes its prose exactly once.
          def prose_exclusions
            super + %i(json_type json_content)
          end
        end
      end
    end
  end
end
