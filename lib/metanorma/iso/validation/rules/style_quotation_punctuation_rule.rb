# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: punctuation inside closing quotation marks
        # (ISO House Style, Punctuation > Quotation marks). The full
        # stop is placed inside the quotation marks only when the
        # quotation is a complete sentence; when the quotation is part
        # of the enclosing sentence, the stop stays outside.
        #
        # Heuristic-limited by design. The rule flags the unambiguous
        # direction only: a SHORT quotation that is fragment-shaped at
        # both ends — it begins and ends in a lowercase word and
        # carries no sentence-ending punctuation of its own — carrying
        # a full stop inside the closing quotes. Quoted complete
        # sentences begin with a capital letter and are exempt by
        # construction; a fragment capitalized at both ends cannot be
        # told apart from a sentence and stays unflagged.
        class StyleQuotationPunctuationRule < StyleRule
          policy category: "Punctuation > Quotation marks",
                 rule: "the full stop goes inside the quotation marks only for a complete quoted sentence; partial quotations take the stop outside",
                 source: :house_style, mn_category: :style

          # A fragment-shaped quoted span (lowercase first and last
          # word; letters, digits, spaces and basic punctuation in
          # between — in particular no internal sentence-ending
          # punctuation), terminated by a full stop inside the closing
          # quotes. Covers straight and typographic quotes. The
          # 50-character span cap keeps block quotations out of scope.
          QUOTED_STOP_INSIDE_REGEX = /
            ["“]
            [a-z]
            [A-Za-z0-9 ,;:%()'’‐-―-]{0,48}
            [a-z]
            [.]["”]
          /x.freeze

          LABEL = "style: full stop inside the quotation marks after a " \
                  "partial quotation (place the stop outside)".freeze

          def scan_text(node, text)
            finding_if_match(node, text, QUOTED_STOP_INSIDE_REGEX, LABEL)
          end
        end
      end
    end
  end
end
