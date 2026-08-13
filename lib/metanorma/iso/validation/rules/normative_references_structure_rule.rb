# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_24: normative references must not contain subclauses or nested
        # references sections. Source: bibliography/references[@normative='true']
        # must have only bibitem children.
        class NormativeReferencesStructureRule < Base
          code "ISO_24"

          def applicable?(context)
            !context.root.nil? && !context.root.bibliography.nil?
          end

          def check(context)
            issues = []
            each_normative_references(context.root.bibliography) do |refs|
              next if structure_valid?(refs)
              issues << build_issue(location: "references[@normative='true']",
                                    params: [])
            end
            issues
          end

          private

          def each_normative_references(bibliography)
            return enum_for(__method__, bibliography) unless block_given?

            Array(bibliography.references).each do |section|
              next unless normative?(section)
              yield(section)
            end
          end

          def normative?(section)
            section.normative == true || section.normative.to_s == "true"
          end

          # The vendored StandardReferencesSection model only preserves
          # bibitems via :references. Nested <clause> or <references>
          # children would be silently dropped during from_xml, so we cannot
          # detect them on the typed model. Until the model is extended
          # (TODO 33 upstream), this rule flags ISO_24 only when a normative
          # references section is unexpectedly empty of bibitems — a proxy
          # for "wrong children present, bibitems missing". This preserves
          # existing behavior on the canonical case (a normref with bibitems
          # and only bibitems).
          def structure_valid?(refs)
            !Array(refs.references).empty?
          end
        end
      end
    end
  end
end
