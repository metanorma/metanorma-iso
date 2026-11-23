# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Keeps a rule class as the registry, profile and policy-metadata
        # identity while the declarative engine performs its structural
        # check. The class supplies +declarative_rule+, +#declarative_issue+
        # (finding to Issue, through +build_issue+ so citations are
        # unchanged). Retained +#legacy_check+ methods are differential-test
        # oracles; runtime projection failures are explicit errors.
        module DeclarativeDispatch
          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            def declarative_rule(*ids)
              @declarative_rule_ids = ids.map(&:to_s).freeze
            end

            def declarative_rule_ids
              return @declarative_rule_ids if @declarative_rule_ids
              return [] unless superclass.include?(DeclarativeDispatch)

              superclass.declarative_rule_ids
            end
          end

          # Projection nodes describe semantic XML. Existing model labels are
          # retained for the ISO section/list families this adapter serves.
          def projected_location(node)
            names = {
              "sections" => "IsoSections", "annex" => "IsoAnnexSection",
              "clause" => "IsoClauseSection", "terms" => "IsoTermsSection",
              "references" => "StandardReferencesSection", "ol" => "OrderedList",
              "ul" => "UnorderedList", "appendix" => "IsoClauseSection",
              "foreword" => "IsoForewordSection", "introduction" => "IsoClauseSection",
              "definitions" => "DefinitionSection",
            }
            name = names.fetch(node.name)
            id = node["id"]
            id.nil? || id.empty? ? name : "#{name}##{id}"
          end

          def check(context)
            findings = DeclarativeCatalog.findings_for(self.class, context)

            findings.map { |finding| declarative_issue(finding, context) }
          end
        end
      end
    end
  end
end
