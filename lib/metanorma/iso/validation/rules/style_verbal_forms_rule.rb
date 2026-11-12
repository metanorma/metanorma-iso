# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: "will" is not an ISO verbal form. Requirements
        # are expressed with "shall"; statements of permission and
        # possibility use "may" and "can" (StyleAmbigWordsRule covers
        # the ambiguous modals "might", "could" and "need to").
        #
        # Heuristic-limited by design: the rule flags only the closed
        # list of requirement-shaped continuations of "will" (a bare
        # "will" + verb-phrase). Future-tense narration in informative
        # text is not distinguished from requirement phrasing and will
        # be reported too; the finding is a warning for the editor.
        class StyleVerbalFormsRule < StyleRule
          policy category: "Verbal forms",
                 rule: "requirements are expressed with 'shall' — not 'will' or other verbal forms",
                 source: :house_style, mn_category: :style

          # Closed list: requirement-shaped continuations of "will".
          WILL_REQUIREMENT_REGEX =
            /\bwill\s+(?:(?:not\s+)?be|apply|contain|consist)\b/i.freeze

          LABEL = "style: '%s' (verbal form: use 'shall' for requirements)".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, WILL_REQUIREMENT_REGEX, LABEL)
          end
        end
      end
    end
  end
end
