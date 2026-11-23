# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_39: scope clause must not contain subclauses (should be succinct
        # prose per ISO/IEC DIR 2, 14.4).
        class ScopeSubclausesRule < Base
          include DeclarativeDispatch

          code "ISO_39"
          declarative_rule "iso.scope.no-subclauses"

          policy category: "Document structure",
                 rule: "the Scope must not contain subclauses",
                 source: :directives, directives: "14.4",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil?
          end

          private

          # The finding's node is the first subclause. Its parent's position
          # among scope clauses selects the same clause in the source model.
          def declarative_issue(finding, context)
            index = finding.node.parent.xpath(
              "preceding-sibling::m:clause[@type='scope']",
              DeclarativeCatalog::NAMESPACES,
            ).size
            scope = each_scope_clause(context.root).to_a.fetch(index)
            build_issue(location: model_location(scope), params: [])
          end

          def legacy_check(context)
            issues = []
            each_scope_clause(context.root) do |scope|
              subclauses = Array(scope.clause)
              next if subclauses.empty?

              issues << build_issue(location: model_location(scope),
                                    params: [])
            end
            issues
          end

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
