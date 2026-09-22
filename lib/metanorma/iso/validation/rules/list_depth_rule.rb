# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: lists deeper than 4 levels are discouraged.
        # Source: validate_list.rb#li_depth_validate.
        # Emitted via STANDOC_48 (generic style warning).
        class ListDepthRule < Base
          code "STANDOC_48"

          MAX_DEPTH = 4

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_top_level_list(context.root) do |list, parent|
              depth = max_descendant_depth(list)
              next if depth <= MAX_DEPTH

              issues << build_issue(
                location: model_location(parent),
                params: ["List more than #{MAX_DEPTH} levels deep: #{depth}"]
              )
            end
            issues
          end

          private

          def each_top_level_list(root)
            return enum_for(__method__, root) unless block_given?

            visit_clause_holder(root.sections) { |h| yield_lists(h) { |l| yield(l, h) } } if root.sections
            Array(root.annex).each { |a| visit_clause_holder(a) { |h| yield_lists(h) { |l| yield(l, h) } } }
          end

          def visit_clause_holder(holder, &block)
            return unless holder

            yield(holder)
            return unless holder.class.method_defined?(:clause)

            Array(holder.clause).each { |c| visit_clause_holder(c, &block) }
          end

          def yield_lists(holder)
            Array(holder.ordered_lists).each { |l| yield(l) } if holder.class.method_defined?(:ordered_lists)
            Array(holder.unordered_lists).each { |l| yield(l) } if holder.class.method_defined?(:unordered_lists)
          end

          # Depth of a list = 1 + max(depth of nested lists).
          # A flat list has depth 1; nested lists add 1 each level.
          def max_descendant_depth(list)
            nested = nested_lists(list)
            return 1 if nested.empty?

            1 + nested.map { |l| max_descendant_depth(l) }.max
          end

          def nested_lists(list)
            items = Array(list.listitem) if list.class.method_defined?(:listitem)
            return [] if items.empty?

            nested = []
            items.each do |item|
              nested.concat(Array(item.ordered_lists)) if item.class.method_defined?(:ordered_lists)
              nested.concat(Array(item.unordered_lists)) if item.class.method_defined?(:unordered_lists)
            end
            nested
          end
        end
      end
    end
  end
end
