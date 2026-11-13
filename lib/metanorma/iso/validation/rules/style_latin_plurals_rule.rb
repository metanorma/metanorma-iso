# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for wrong English plurals of Latin and Greek
        # loanwords, and for singular agreement of "data" (ISO House
        # Style: "data" is plural — "data are", not "data is").
        #
        #   "criterias" → criteria, "phenomenons" → phenomena,
        #   "curriculums" → curricula, "memorandums" → memoranda,
        #   "millenniums" → millennia, "spectrums" → spectra,
        #   "stratums" → strata, "crisises" → crises,
        #   "addendums" → addenda.
        #
        # Possessive forms ("criteria's", "data's") are not flagged: the
        # apostrophe-s forms are grammatical and out of scope.
        class StyleLatinPluralsRule < StyleRule
          code "ISO_100"

          policy category: "Spelling and wording > Latin and Greek wording",
                 rule: "use the Latin/Greek plurals ('criteria', 'phenomena'); 'data' is plural",
                 source: :house_style, mn_category: :style

          LATIN_PLURALS = {
            /\bcriterias\b/i => "criterias (use 'criteria')",
            /\bphenomenons\b/i => "phenomenons (use 'phenomena')",
            /\bcurriculums\b/i => "curriculums (use 'curricula')",
            /\bmemorandums\b/i => "memorandums (use 'memoranda')",
            /\bmillenniums\b/i => "millenniums (use 'millennia')",
            /\bspectrums\b/i => "spectrums (use 'spectra')",
            /\bstratums\b/i => "stratums (use 'strata')",
            /\bcrisises\b/i => "crisises (use 'crises')",
            /\baddendums\b/i => "addendums (use 'addenda')"
          }.freeze

          # "data is", "data was", "data has" — House Style treats
          # "data" as a plural noun ("data are", "data were",
          # "data have"). "metadata is" is not matched: the \b before
          # "data" excludes mid-word occurrences.
          DATA_SINGULAR_REGEX = /\bdata\s+(is|was|has)\b/i.freeze

          DATA_SINGULAR_LABEL =
            "style: 'data %s' (House Style: 'data' is plural — " \
            "use 'data are', 'data were', 'data have')".freeze

          def scan_text(node, text)
            findings = []
            LATIN_PLURALS.each do |regex, label|
              findings.concat(finding_if_match(node, text, regex, "style: #{label}"))
            end
            findings.concat(
              findings_for_matches(node, text, DATA_SINGULAR_REGEX, DATA_SINGULAR_LABEL)
            )
            findings
          end
        end
      end
    end
  end
end
