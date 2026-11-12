# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: the abbreviations "min.", "max." and "lab."
        # are confined to tables and figures (ISO House Style,
        # Abbreviations and contractions: abbreviated terms may be used
        # in tables and figures; the words are written in full in
        # text).
        #
        # The StyleRule paragraph walk only reaches prose paragraphs:
        # table-cell content holds inline text or block paragraphs, not
        # paragraph holders, so cells are excluded structurally. "ca."
        # is governed by StyleCaCfRule (write "approximately").
        class StyleAbbrevTablesOnlyRule < StyleRule
          policy category: "Abbreviations and contractions",
                 rule: "write 'minimum', 'maximum' and 'laboratory' in full in text; 'min.', 'max.' and 'lab.' are for tables and figures",
                 source: :house_style, mn_category: :style

          PROSE_ABBREV_REGEX = /\b(min|max|lab)\./.freeze

          LABEL = "style: '%s.' (write the word in full in text; " \
                  "abbreviations are for tables and figures)".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, PROSE_ABBREV_REGEX, LABEL)
          end
        end
      end
    end
  end
end
