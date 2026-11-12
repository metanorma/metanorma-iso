# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for the plural number contraction "nos."
        # (ISO House Style): the singular abbreviation of "number" is
        # "no." with the full stop, but its plural is "nos" WITHOUT
        # the full stop. Only the plural form "nos." is flagged; the
        # singular "no." is correct and is left alone.
        #
        # The match is case-restricted to "nos."/"Nos." (the
        # contraction forms) so that all-caps "NOS" acronyms at a
        # sentence end are not flagged, and requires the full stop to
        # be followed by whitespace or end of text.
        class StyleNoNosRule < StyleRule
          code "ISO_104"

          policy category: "Abbreviated terms > Abbreviations and contractions",
                 rule: "the plural of 'no.' is 'nos', without a full stop",
                 source: :house_style, mn_category: :style

          NOS_DOT_REGEX = /\b[Nn]os\.(?=\s|$)/.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, NOS_DOT_REGEX,
              "style: '%s' (House Style: the plural of 'no.' is 'nos', " \
              "without the full stop)"
            )
          end
        end
      end
    end
  end
end
