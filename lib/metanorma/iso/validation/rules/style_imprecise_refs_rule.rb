# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for imprecise positional references (ISO House
        # Style: cite the element by its identifier -- "see Clause 5",
        # "see Figure 3" -- not "the following clause", "the figure
        # above", "the table below", "the preceding section").
        class StyleImpreciseRefsRule < StyleRule
          code "ISO_94"

          policy category: "Referencing > References within the document",
                 rule: "cite the element by its identifier, not 'the following clause' or 'the figure above'",
                 source: :house_style, mn_category: :references

          IMPRECISE_REFS_REGEX = /
            \b(the\ following\ clauses?
              |the\ following\ sections?
              |the\ preceding\ clauses?
              |the\ preceding\ sections?
              |the\ figures?\ above
              |the\ tables?\ below)
          /xi.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, IMPRECISE_REFS_REGEX,
              "style: '%s' (cite the element by its identifier)"
            )
          end
        end
      end
    end
  end
end
