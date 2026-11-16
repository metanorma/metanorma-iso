# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for self-references by document title (ISO
        # House Style: refer to the current document as "this document",
        # not "this Standard", "this International Standard" or "this
        # part of ISO ...").
        class StyleSelfReferenceRule < StyleRule
          code "ISO_113"

          policy category: "Referencing > References in a document to itself",
                 rule: "refer to the current document as 'this document'",
                 source: :house_style, mn_category: :references

          SELF_REFERENCE_REGEX = /
            \b(this\ International\ Standard
              |this\ Standard
              |this\ part\ of\ ISO)
          /xi.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, SELF_REFERENCE_REGEX,
              "style: '%s' (use 'this document')"
            )
          end
        end
      end
    end
  end
end
