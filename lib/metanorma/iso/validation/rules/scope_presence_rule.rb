# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_29: document must contain a Scope clause (sections/clause
        # with type="scope"). Flags when no clause in sections has that type.
        class ScopePresenceRule < Base
          code "ISO_29"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            clauses = Array(context.root.sections&.clause)
            return [] if clauses.any? { |clause| scope_clause?(clause) }

            [build_issue(location: "sections/clause[@type='scope']", params: [])]
          end

          private

          def scope_clause?(clause)
            clause.type == "scope"
          end
        end
      end
    end
  end
end
