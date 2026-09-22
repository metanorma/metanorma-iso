# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_19: every first-level subclause must have a title.
        # Walks every top-level container (sections + annexes) and flags
        # each direct child clause/terms/references that lacks a title.
        # ISO/IEC DIR 2, 22.2.
        class TitleFirstLevelRule < Base
          code "ISO_19"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_top_level_container(context.root) do |container|
              parent_label = title_text_of(container)
              each_titled_child(container) do |child|
                next if has_title?(child)
                issues << build_issue(location: model_location(child),
                                      params: [parent_label])
              end
            end
            issues
          end

          private

          def each_top_level_container(root)
            return enum_for(__method__, root) unless block_given?

            sections = root.sections
            yield(sections) if sections
            Array(root.annex).each { |annex| yield(annex) }
          end

          # Yields each direct child of a container that is a "titled"
          # section type (clause, terms, references).
          def each_titled_child(container)
            return enum_for(__method__, container) unless block_given?

            yield_collection(container, :clause) { |c| yield(c) }
            yield_collection(container, :terms) { |t| yield(t) }
            yield_collection(container, :references) { |r| yield(r) }
          end

          def yield_collection(holder, attr_name)
            return unless holder.class.method_defined?(attr_name)

            value = holder.public_send(attr_name)
            Array(value).each { |item| yield(item) }
          end

          def has_title?(node)
            return false unless node.class.method_defined?(:title)

            title = node.title
            return false if title.nil?

            !extract_text(title).strip.empty?
          end

          def title_text_of(node)
            return node.class.name.split("::").last unless has_title?(node)

            extract_text(node.title).strip
          end
        end
      end
    end
  end
end
