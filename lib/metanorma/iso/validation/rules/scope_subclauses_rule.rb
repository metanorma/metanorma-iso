# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_39: scope clause must not contain subclauses (should be succinct
        # prose per ISO/IEC DIR 2, 14.4).
        class ScopeSubclausesRule < Base
          code "ISO_39"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_scope_clause(context.root) do |scope|
              subclauses = Array(scope.clause)
              next if subclauses.empty?

              issues << build_issue(location: model_location(scope),
                                    params: [])
            end
            issues
          end

          private

          def each_scope_clause(root)
            return enum_for(__method__, root) unless block_given?

            clauses = Array(root.sections&.clause)
            clauses.each do |clause|
              yield(clause) if clause.type == "scope"
            end
          end
        end
      end
    end
  end
end
