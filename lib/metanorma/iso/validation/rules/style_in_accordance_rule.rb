# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning for "according to" inside requirement
        # sentences (ISO House Style): in normative text, sources are
        # cited with "in accordance with" ("The test shall be carried
        # out in accordance with ISO 12345"), not "according to".
        #
        # A sentence is treated as a requirement when it contains
        # "shall" or "must not", or starts with an imperative verb
        # from a closed list. Declarative sentences ("According to the
        # manufacturer, ...") pass.
        class StyleInAccordanceRule < StyleRule
          policy category: "Spelling and wording",
                 rule: "in requirement sentences cite sources with " \
                       "'in accordance with', not 'according to'",
                 source: :house_style, mn_category: :style

          ACCORDING_TO_REGEX = /\baccording\s+to\b/i.freeze

          REQUIREMENT_REGEX = /\bshall\b|\bmust\s+not\b/i.freeze

          # Base-form verbs that open an imperative instruction
          # ("Apply a load of 10 N."). Kept closed: a wrong word here
          # would misclassify declarative sentences as requirements.
          IMPERATIVE_VERBS = %w[
            apply calibrate consider connect ensure follow include measure
            mount perform place protect provide record refer remove repeat
            report select specify store take use verify avoid check consult
            clean calculate determine identify carry
          ].freeze

          IMPERATIVE_START_REGEX =
            /\A(?:#{IMPERATIVE_VERBS.join("|")})\b/i.freeze

          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            Metanorma::Iso::Validation::SentenceScan.sentences(text)
              .filter_map do |sentence|
              next unless sentence.text.match?(ACCORDING_TO_REGEX)
              next unless requirement_sentence?(sentence.text)

              build_warning(
                node,
                "style: 'according to' in a requirement sentence " \
                "(use 'in accordance with')"
              )
            end
          end

          private

          def requirement_sentence?(sentence)
            sentence.match?(REQUIREMENT_REGEX) ||
              sentence.match?(IMPERATIVE_START_REGEX)
          end
        end
      end
    end
  end
end
