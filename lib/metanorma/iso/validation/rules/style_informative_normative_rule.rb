# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: the normative or informative status of an
        # annex, clause, figure or table is never stated in
        # cross-reference text (ISO House Style). The verbal form of
        # the requirement carries the status — "Annex A" with "see"
        # cites informatively, "shall comply with Annex B" normatively;
        # writing "the informative Annex B" duplicates it.
        #
        # Only the subject-first wording is flagged ("informative Annex
        # B"). The parenthetical designator "Annex B (informative)" and
        # predicative sentences ("Annex B is informative") are correct
        # and are not matched.
        class StyleInformativeNormativeRule < StyleRule
          policy category: "Referencing > Normative and informative",
                 rule: "do not name the normative/informative status of a cross-referenced element in text — the verbal form of the requirement states it",
                 source: :house_style, mn_category: :references

          NORM_INFO_REF_REGEX =
            /\b(?:normative|informative)\s+(?:annex|clause|figure|table)\s+[A-Z0-9]/i.freeze

          LABEL = "style: '%s' (do not name the normative/informative " \
                  "status of a cross-referenced element; the verbal form " \
                  "of the requirement states it)".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, NORM_INFO_REF_REGEX, LABEL)
          end
        end
      end
    end
  end
end
