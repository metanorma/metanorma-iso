# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for personal pronouns (ISO House Style:
        # impersonal tone in technical documents). "I", "we", "our",
        # "you", "your", "yours" as standalone words are flagged. The
        # list is kept tight: "us" is excluded because a case-insensitive
        # match collides with the country code "US"; "I" is matched
        # case-sensitively to avoid lowercase roman-numeral and
        # identifier noise. As with every style warning, the noise level
        # of a quoted string is accepted (severity is a warning).
        class StyleImpersonalRule < StyleRule
          code "ISO_93"

          policy category: "Plain language",
                 rule: "use an impersonal tone; avoid 'I', 'we', 'you' and other personal pronouns",
                 source: :house_style, mn_category: :style

          PRONOUN_I_REGEX = /\b(I)\b/.freeze
          PRONOUN_WE_YOU_REGEX = /\b(we|our|you|your|yours)\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(node, text, PRONOUN_I_REGEX,
                                 "style: '%s' (use impersonal wording)") +
              findings_for_matches(node, text, PRONOUN_WE_YOU_REGEX,
                                   "style: '%s' (use impersonal wording)")
          end
        end
      end
    end
  end
end
