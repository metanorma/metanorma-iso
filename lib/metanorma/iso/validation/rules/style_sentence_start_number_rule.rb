# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for sentences that start with a numeral (ISO
        # House Style): write the number as a word ("Three samples
        # were tested", not "3 samples were tested").
        #
        # Sentence boundaries come from SentenceScan. Exemptions:
        # label-style openings ("3. Do this" enumerations), and
        # mathematical content, which StyleRule#prose_exclusions
        # strips. Table-cell text does not flow through the paragraph
        # walk at all, so cells are structurally out of scope. Years
        # and standards identifiers opening a sentence still flag: the
        # House Style makes no exception for them.
        class StyleSentenceStartNumberRule < StyleRule
          policy category: "Numbers, values and dates > Numbers",
                 rule: "do not start a sentence with a numeral; write " \
                       "the number as a word ('Three samples ...')",
                 source: :house_style, mn_category: :style

          LEADING_DIGIT_REGEX = /\A\d/.freeze

          # List-item-label style: "3. Do this", "5) Check that", and
          # the bare label sentence "3." that a split leaves behind.
          LIST_LABEL_REGEX = /\A\d+[.)](\s|\z)/.freeze

          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            Metanorma::Iso::Validation::SentenceScan.sentences(text)
              .filter_map do |sentence|
              next unless sentence.text.match?(LEADING_DIGIT_REGEX)
              next if sentence.text.match?(LIST_LABEL_REGEX)

              build_warning(
                node,
                format(
                  "style: sentence starts with a numeral ('%s') " \
                  "(write the number as a word)",
                  leading_number(sentence.text)
                )
              )
            end
          end

          private

          def leading_number(sentence)
            sentence[/\A[\d.,]+/] || sentence[0, 8]
          end
        end
      end
    end
  end
end
