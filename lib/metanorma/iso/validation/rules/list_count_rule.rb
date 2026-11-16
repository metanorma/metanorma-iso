# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: no more than one ordered list per clause/annex
        # (ISO house style). Source: validate_list.rb#ol_count_validate.
        class ListCountRule < Base
          code "ISO_58"

          policy category: "Lists",
                 rule: "avoid more than one numbered list in a clause/subclause",
                 source: :house_style, mn_category: :style

          MAX_OL_PER_CLAUSE = 1

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_clause_with_lists(context.root) do |holder|
              ols = direct_ordered_lists(holder)
              next if ols.size <= MAX_OL_PER_CLAUSE

              issues << build_issue(
                location: model_location(holder),
                params: ["More than 1 ordered list in a numbered clause: #{ols.size}"]
              )
            end
            issues
          end

          private

          def each_clause_with_lists(root)
            return enum_for(__method__, root) unless block_given?

            visit_clause_holder(root.sections) { |h| yield(h) } if root.sections
            Array(root.annex).each { |a| visit_clause_holder(a) { |h| yield(h) } }
          end

          def visit_clause_holder(holder, &block)
            return unless holder

            yield(holder)
            return unless holder.class.method_defined?(:clause)

            Array(holder.clause).each { |c| visit_clause_holder(c, &block) }
          end

          def direct_ordered_lists(holder)
            return [] unless holder.class.method_defined?(:ordered_lists)

            Array(holder.ordered_lists)
          end
        end
      end
    end
  end
end
