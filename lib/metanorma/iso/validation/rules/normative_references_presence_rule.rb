# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_30: document must contain normative references
        # (bibliography/references[@normative = 'true']).
        class NormativeReferencesPresenceRule < Base
          include DeclarativeDispatch

          code "ISO_30"
          declarative_rule "iso.normative-references.presence"

          policy category: "Document structure",
                 rule: "the document must contain a Normative references clause",
                 source: :directives, directives: "15.3",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil?
          end

          private

          def declarative_issue(_finding, _context)
            build_issue(location: "BibliographySection[normative]", params: [])
          end

          def legacy_check(context)
            bibliography = context.root.bibliography
            return [] unless bibliography

            refs_sections = Array(bibliography.references)
            return [] if refs_sections.any? { |section| normative?(section) }

            [build_issue(location: "BibliographySection[normative]",
                        params: [])]
          end

          # The vendored IsoDocument model types `normative` as :boolean.
          # In the metanorma-internal XML it is the string "true"; lutaml-model
          # parses both. We compare against true to be unambiguous.
          def normative?(references_section)
            references_section.normative == true ||
              references_section.normative.to_s == "true"
          end
        end
      end
    end
  end
end
