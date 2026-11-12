# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "assure"/"ensure" confusion (ISO House
        # Style): "ensure" removes doubt about a thing or a clause
        # ("ensure that the measurement is traceable"), "assure"
        # removes doubt in a person ("assure the user").
        #
        # Conservative by construction: "assure/assures/assured" is
        # flagged only when its object is a thing — a "that" clause, a
        # closed list of data/quality nouns, or an article plus a word
        # outside the person-word list. "Assure the user" and friends
        # pass.
        class StyleAssureEnsureRule < StyleRule
          code "ISO_71"

          policy category: "Grammar",
                 rule: "use 'ensure' (not 'assure') when the object is a " \
                       "thing or a that-clause; 'assure' is reserved for " \
                       "people ('assure the user')",
                 source: :house_style, mn_category: :style

          ASSURE_THAT_REGEX = /\bassure[ds]?\s+that\b/i.freeze

          ASSURE_OBJECT_REGEX = /\bassure[ds]?\s+(?:the|a|an)\s+([a-z]+)\b/i.freeze

          ASSURED_NOUN_REGEX =
            %r{\bassured\s+(?:data|quality|accuracy|results?|performance|values?|operation|compliance)\b}i.freeze

          # People: "assure" with a person as its object is correct.
          PERSON_WORDS = %w[
            user users reader readers customer customers client clients
            person persons people operator operators installer installers
            manufacturer manufacturers supplier suppliers purchaser
            purchasers buyer buyers owner owners everyone anyone somebody
            staff personnel team committees committee member members
            delegate delegates authority authorities regulator regulators
            public consumer consumers subscriber subscribers
          ].freeze

          # Strip the duplicated json_* text copies so each paragraph
          # contributes its prose exactly once.
          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            findings_for_matches(
              node, text, ASSURE_THAT_REGEX,
              "style: '%s' (use 'ensure that' for clauses)"
            ) + findings_for_matches(
              node, text, ASSURED_NOUN_REGEX,
              "style: '%s' (use 'ensure' for things)"
            ) + findings_for_inanimate_objects(node, text)
          end

          private

          # "assure(s|d) the|a|an X": flag unless X is a person word.
          def findings_for_inanimate_objects(node, text)
            text.scan(ASSURE_OBJECT_REGEX).filter_map do |(word)|
              next if PERSON_WORDS.include?(word.downcase)

              build_warning(
                node,
                "style: 'assure' with a thing as its object " \
                "'#{match_text(text, word)}' (use 'ensure')"
              )
            end
          end

          def match_text(text, word)
            text.match(/assure[ds]?\s+(?:the|a|an)\s+#{word}\b/i).to_s
          end
        end
      end
    end
  end
end
