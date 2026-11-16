# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "that"/"which" in relative clauses (ISO
        # House Style): defining clauses take "that" without commas
        # ("products that comply"); non-defining clauses are set off by
        # commas and take "which" (", which").
        #
        # General detection of comma-less "which" after an arbitrary
        # noun is too noisy to be usable, so this rule implements the
        # two conservative subsets only, and every other "which"
        # context passes:
        #
        #   - comma-less "which" directly after the House Style's
        #     example nouns ("those", "products", "documents",
        #     "samples") — the defining-clause direction;
        #   - ", that" — the clearly-wrong non-defining direction
        #     (a comma marks a non-defining clause, which takes
        #     "which"). Legitimate comma-preceded connectors
        #     ("provided that", "so that", "and that", ...) are
        #     exempted by a closed whitelist.
        class StyleThatWhichRule < StyleRule
          code "ISO_115"

          policy category: "Grammar > Defining and non-defining relative clauses",
                 rule: "use 'that' in defining relative clauses without " \
                       "commas ('products that comply'); a comma marks a " \
                       "non-defining clause, which takes 'which'",
                 source: :house_style, mn_category: :style

          WHICH_AFTER_NOUN_REGEX =
            /\b(?:those|products|documents|samples)\s+which\b/i.freeze

          # ", that" with the legitimate connectors exempted:
          # subordinating conjunctions that routinely follow a comma
          # ("..., provided that", "..., so that"), coordination
          # ("..., and that"), and the discourse marker ", that is,".
          COMMA_THAT_REGEX = /
            ,\s+
            (?!provided\s|given\s|except\s|such\s|so\s|now\s|assuming\s
               |seeing\s|in\s+order\s|in\s+that\s|that\s+is\b
               |and\s|or\s|but\s|nor\s|yet\s|if\s|as\s)
            that\b
          /ix.freeze

          # Strip the duplicated json_* text copies so each paragraph
          # contributes its prose exactly once.
          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            findings_for_matches(
              node, text, WHICH_AFTER_NOUN_REGEX,
              "style: '%s' (a defining clause takes 'that': " \
              "'products that comply')"
            ) + findings_for_matches(
              node, text, COMMA_THAT_REGEX,
              "style: ', that' (a comma marks a non-defining clause, " \
              "which takes 'which')"
            )
          end
        end
      end
    end
  end
end
