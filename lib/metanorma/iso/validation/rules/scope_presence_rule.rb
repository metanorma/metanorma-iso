# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_29: document must contain a Scope clause (sections/clause
        # with type="scope"). Flags when no clause in sections has that type.
        class ScopePresenceRule < Base
          include DeclarativeDispatch

          code "ISO_29"
          declarative_rule "iso.scope.presence"

          policy category: "Document structure",
                 rule: "the document must contain a Scope clause",
                 source: :directives, directives: "14.3",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil?
          end

          private

          def declarative_issue(_finding, _context)
            build_issue(location: "IsoSections", params: [])
          end

          def legacy_check(context)
            clauses = Array(context.root.sections&.clause)
            return [] if clauses.any? { |clause| scope_clause?(clause) }

            [build_issue(location: "IsoSections", params: [])]
          end

          def scope_clause?(clause)
            clause.type == "scope"
          end
        end
      end
    end
  end
end
