# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_30: document must contain normative references
        # (bibliography/references[@normative = 'true']).
        class NormativeReferencesPresenceRule < Base
          code "ISO_30"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            bibliography = context.root.bibliography
            return [] unless bibliography

            refs_sections = Array(bibliography.references)
            return [] if refs_sections.any? { |section| normative?(section) }

            [build_issue(location: "BibliographySection[normative]",
                        params: [])]
          end

          private

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
