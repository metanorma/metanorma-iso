# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for the "(s)" pluralization ("sample(s)") (ISO
        # House Style: avoid it unless the term is simple; use the
        # plural, or "one or more"). The lookbehind restricts the match
        # to suffixed occurrences (a word character directly before the
        # parenthesis), so a standalone "(s)" in text is not flagged.
        class StylePluralSTermRule < StyleRule
          PLURAL_S_REGEX = /(?<=\w)(\(\s*s\s*\))/.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, PLURAL_S_REGEX,
              "style: '%s' pluralization (use the plural, or 'one or more')"
            )
          end
        end
      end
    end
  end
end
