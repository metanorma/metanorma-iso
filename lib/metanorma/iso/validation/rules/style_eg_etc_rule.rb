# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "e.g."/"i.e." usage (ISO House Style):
        #
        #   - "e.g." and "etc." must never appear in the same sentence;
        #   - no comma follows "e.g." or "i.e.".
        #
        # The same-sentence check spans the gap between the two matches
        # and only reports when no sentence break ([.!?] + whitespace)
        # lies between them.
        class StyleEgEtcRule < StyleRule
          policy category: "e.g., etc. family",
                 rule: "'e.g.' and 'etc.' never appear in the same sentence; no comma follows 'e.g.'/'i.e.'",
                 source: :house_style, mn_category: :style

          EG_REGEX = /\be\.g\./i.freeze
          ETC_REGEX = /\betc\./i.freeze
          COMMA_AFTER_EG_IE_REGEX = /\b(e\.g\.|i\.e\.),/i.freeze
          SENTENCE_BREAK_REGEX = /[.!?]\s+/.freeze

          def scan_text(node, text)
            findings = findings_for_matches(
              node, text, COMMA_AFTER_EG_IE_REGEX,
              "style: comma after '%s' (no comma follows 'e.g.'/'i.e.')"
            )
            findings << same_sentence_finding(node, text)
            findings.compact
          end

          private

          def same_sentence_finding(node, text)
            return unless eg_and_etc_same_sentence?(text)

            build_warning(
              node,
              "style: 'e.g.' and 'etc.' in the same sentence (use one " \
              "or the other)"
            )
          end

          def eg_and_etc_same_sentence?(text)
            eg = text.match(EG_REGEX)
            etc = text.match(ETC_REGEX)
            return false unless eg && etc

            lo, hi = span_between(eg, etc)
            return false if lo >= hi

            !text[lo...hi].match?(SENTENCE_BREAK_REGEX)
          end

          # Open interval from the end of the earlier match to the start
          # of the later one. Using the earlier match's end keeps "etc."
          # own trailing period out of the span when it comes first.
          def span_between(eg, etc)
            if eg.begin(0) < etc.begin(0)
              [eg.end(0), etc.begin(0)]
            else
              [etc.end(0), eg.begin(0)]
            end
          end
        end
      end
    end
  end
end
