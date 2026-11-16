# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: plurals are not formed with the apostrophe
        # (ISO House Style, Punctuation > Apostrophes). "the 1990s",
        # "in the 80s", "three CPUs" are correct; "1990's", "80's" and
        # "three CPU's" are not.
        #
        # Conservative scope: only apostrophe forms whose base is a
        # multi-digit number, or an acronym preceded by a count ("three
        # CPU's"), are flagged. Bare acronym apostrophe forms ("the
        # CPU's registers") stay unflagged: the possessive reading
        # cannot be ruled out from flat text.
        class StyleApostrophePluralsRule < StyleRule
          code "ISO_70"

          policy category: "Punctuation > Apostrophes",
                 rule: "do not form plurals with the apostrophe ('the 1990s', not 'the 1990's')",
                 source: :house_style, mn_category: :style

          # "1990's", "80's" — the decade/number plural form. A single
          # digit is excluded: "step 5's caption" is a possessive and
          # cannot be told apart from a plural in flat text.
          DIGIT_PLURAL_REGEX = /\b\d{2,4}'s\b/.freeze

          # "three CPU's", "4 GPU's" — an acronym pluralized after an
          # explicit count. Possessives are never preceded by a count.
          ACRONYM_PLURAL_REGEX = /
            (?:\b\d+|\b(?:two|three|four|five|six|seven|eight|nine|ten))\s+
            ([A-Z]{2,})'s\b
          /x.freeze

          LABEL = "style: '%s' (do not form plurals with the apostrophe)".freeze

          def scan_text(node, text)
            findings = findings_for_matches(node, text, DIGIT_PLURAL_REGEX, LABEL)
            acronym_plurals(text).each do |plural|
              findings << build_warning(node, format(LABEL, plural))
            end
            findings
          end

          private

          # The acronym captured in group 1; each scan result is a
          # one-element capture array.
          def acronym_plurals(text)
            text.scan(ACRONYM_PLURAL_REGEX)
                .flatten
                .map { |acronym| "#{acronym}'s" }
                .uniq
          end
        end
      end
    end
  end
end
