# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_43: a clause must not be the only child of its parent
        # (either flatten or have multiple subclauses). Source: any clause
        # whose parent has exactly one subclause. Walks the entire clause
        # tree (sections + annexes + nested subclauses).
        class OnlyChildClauseRule < Base
          code "ISO_43"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            visit_subclause_holders(context.root) do |_parent, subclauses|
              next unless subclauses.size == 1

              issues << build_issue(location: clause_location(subclauses.first),
                                    params: [])
            end
            issues
          end

          private

          # Yields (parent_clause, subclauses_array) for every CLAUSE that
          # contains subclauses. Top-level sections.clause and annex.clause
          # are intentionally excluded — ISO_43 fires only on lone subclauses
          # nested inside another clause (matching Standoc::Utils::SUBCLAUSE_XPATH).
          def visit_subclause_holders(root)
            return enum_for(__method__, root) unless block_given?

            sections = root.sections or return
            walk_subclauses(sections.clause) { |p, c| yield(p, c) }
            Array(root.annex).each do |annex|
              walk_subclauses(annex.clause) { |p, c| yield(p, c) }
            end
          end

          def walk_subclauses(clauses, &block)
            Array(clauses).each do |clause|
              subclauses = Array(clause.clause)
              yield(clause, subclauses)
              walk_subclauses(subclauses, &block)
            end
          end

          def clause_location(clause)
            id = clause.id
            return "clause" if id.nil? || id.to_s.empty?

            "clause##{id}"
          end
        end
      end
    end
  end
end
