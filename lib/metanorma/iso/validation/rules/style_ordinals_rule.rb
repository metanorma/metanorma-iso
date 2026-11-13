# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for ordinal adverbs (ISO House Style: use
        # "first", "second", "third", not "firstly", "secondly",
        # "thirdly").
        class StyleOrdinalsRule < StyleRule
          code "ISO_106"

          policy category: "Numbers, values and dates > Numbers",
                 rule: "write first, second, third rather than firstly, secondly, thirdly",
                 source: :house_style, mn_category: :style

          ORDINAL_ADVERBS_REGEX = /\b(firstly|secondly|thirdly)\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, ORDINAL_ADVERBS_REGEX,
              "style: '%s' (use 'first', 'second', 'third')"
            )
          end
        end
      end
    end
  end
end
