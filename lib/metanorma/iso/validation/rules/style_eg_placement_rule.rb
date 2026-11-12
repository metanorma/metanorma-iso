# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: "e.g." and "i.e." are confined to parentheses
        # (ISO House Style, Abbreviated terms > e.g., etc. and i.e.).
        # Running text uses the words "for example" and "that is".
        #
        # A use is exempt when the abbreviation sits inside
        # parentheses, or at the end of its sentence. Usage after a
        # comma in running text ("... devices, e.g. sensors") is the
        # flagged violation.
        class StyleEgPlacementRule < StyleRule
          code "ISO_86"

          policy category: "Abbreviated terms > e.g., etc. and i.e.",
                 rule: "'e.g.' and 'i.e.' are used only in parentheses — running text writes 'for example' and 'that is'",
                 source: :house_style, mn_category: :style

          EG_IE_REGEX = /\b(?:e\.g\.|i\.e\.)/i.freeze

          # Nothing but sentence punctuation follows: the abbreviation
          # closes its sentence.
          SENTENCE_END_REGEX = /\A[.!?,:;\s]*\z/.freeze

          LABEL = "style: '%s' outside parentheses (use 'for example'/" \
                  "'that is', or place the abbreviation in parentheses)".freeze

          def scan_text(node, text)
            eg_ie_matches(text)
              .group_by(&:to_s)
              .each_value
              .flat_map { |matches| finding_for_group(node, text, matches) }
          end

          private

          # One finding per distinct abbreviation. The extracted
          # paragraph text can repeat content (the model's element-order
          # walk), so a violation is reported only when EVERY copy of
          # the abbreviation sits in running text; one exempt copy
          # (parenthesized or sentence-final) clears the group.
          def finding_for_group(node, text, matches)
            return [] if matches.any? { |m| exempt?(text, m) }

            [build_warning(node, format(LABEL, matches.first.to_s))]
          end

          def eg_ie_matches(text)
            text.to_enum(:scan, EG_IE_REGEX).map { Regexp.last_match }
          end

          def exempt?(text, match)
            in_parentheses?(text, match) || at_sentence_end?(text, match)
          end

          # An unmatched open parenthesis before the match means the
          # abbreviation sits inside parenthetical matter.
          def in_parentheses?(text, match)
            head = text[0...match.begin(0)]
            head.count("(") > head.count(")")
          end

          def at_sentence_end?(text, match)
            SENTENCE_END_REGEX.match?(text[match.end(0)..].to_s)
          end
        end
      end
    end
  end
end
