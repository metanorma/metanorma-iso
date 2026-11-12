# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "family of standards" and "suite of
        # standards" (ISO House Style: use "documents on [subject]
        # developed by [committee]").
        class StyleFamilySuiteRule < StyleRule
          code "ISO_89"

          policy category: "Spelling and wording > Family or suite of standards",
                 rule: "use 'documents on [subject] developed by [committee]', not 'family of standards'",
                 source: :house_style, mn_category: :style

          FAMILY_SUITE_REGEX =
            /\b(famil(?:y|ies) of standards?|suites? of standards?)\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, FAMILY_SUITE_REGEX,
              "style: '%s' (use 'documents on [subject] developed by " \
              "[committee]')"
            )
          end
        end
      end
    end
  end
end
