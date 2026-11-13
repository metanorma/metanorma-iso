# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for bare slashes between words (ISO House
        # Style): the "word/word" construction is avoided — reword
        # with "or", "and", or a hyphen.
        #
        # Conservative scope:
        #   - only lowercase word / lowercase word with spaces around
        #     the slash is flagged ("input / output"); closed-up forms
        #     ("input/output", "TCP/IP", "b/w", "I/O") are exempt;
        #   - "and/or" is exempt here: StyleAmbigWordsRule already
        #     flags it, and double-flagging the same span is noise.
        class StyleBareSlashRule < StyleRule
          code "ISO_73"

          policy category: "Punctuation > Use of /",
                 rule: "avoid the forward slash between words; reword with 'or', 'and' or a hyphen",
                 source: :house_style, mn_category: :style

          SLASH_REGEX = /\b([a-z]+)\s+\/\s+([a-z]+)\b/.freeze

          # "and/or" (in either order around the slash) is reported by
          # StyleAmbigWordsRule; do not duplicate it.
          EXEMPT_WORDS = %w[and or].freeze

          def scan_text(node, text)
            issues = []
            seen = []
            text.scan(SLASH_REGEX) do |left, right|
              next if exempt_pair?(left, right)

              fragment = "#{left} / #{right}"
              next if seen.include?(fragment)

              seen << fragment
              issues << build_warning(
                node,
                "bare slash '#{fragment}': reword with 'or', 'and', " \
                "or a hyphen"
              )
            end
            issues
          end

          private

          def exempt_pair?(left, right)
            EXEMPT_WORDS.include?(left) || EXEMPT_WORDS.include?(right)
          end
        end
      end
    end
  end
end
