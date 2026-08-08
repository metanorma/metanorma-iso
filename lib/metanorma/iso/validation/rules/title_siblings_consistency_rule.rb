# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_20: all sibling clauses within a parent must be consistent —
        # either every sibling has a title or none does. Mixed titling is
        # forbidden. Walks the entire clause tree recursively.
        # ISO/IEC DIR 2, 22.2.
        class TitleSiblingsConsistencyRule < Base
          code "ISO_20"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            visit_holder(context.root.sections) { |label| issues << issue_for(label) } if context.root.sections
            Array(context.root.annex).each { |a| visit_holder(a) { |label| issues << issue_for(label) } }
            issues
          end

          private

          # Yields once for each holder whose children have inconsistent titling.
          def visit_holder(holder, &block)
            return unless holder

            check_siblings(holder, &block)
            recurse_into_children(holder, &block)
          end

          def check_siblings(holder)
            siblings = titled_children_of(holder)
            return if siblings.size < 2

            with_title = siblings.count { |s| has_title?(s) }
            without_title = siblings.size - with_title
            return if with_title.zero? || without_title.zero?

            yield(label_of(holder))
          end

          def recurse_into_children(holder, &block)
            each_child_collection(holder) do |child|
              visit_holder(child, &block)
            end
          end

          def each_child_collection(holder)
            yield_each(holder, :clause) { |c| yield(c) }
            yield_each(holder, :terms) { |t| yield(t) }
            yield_each(holder, :references) { |r| yield(r) }
          end

          def titled_children_of(holder)
            children = []
            each_child_collection(holder) { |c| children << c }
            children
          end

          def yield_each(holder, attr_name)
            return unless holder.class.method_defined?(attr_name)

            Array(holder.public_send(attr_name)).each { |item| yield(item) }
          end

          def has_title?(node)
            return false unless node.class.method_defined?(:title)

            title = node.title
            return false if title.nil?

            !extract_text(title).strip.empty?
          end

          def label_of(node)
            return model_location(node) unless has_title?(node)

            extract_text(node.title).strip
          end

          def issue_for(label)
            build_issue(location: label, params: [label])
          end
        end
      end
    end
  end
end
