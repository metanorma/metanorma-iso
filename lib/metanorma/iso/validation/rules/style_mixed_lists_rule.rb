# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: mixed lists are forbidden. A numbered list (ol)
        # nested inside an unnumbered list (ul), or an unnumbered list
        # nested inside a numbered list, must be restructured (ISO House
        # Style). Same-type nesting (ol in ol, ul in ul) is permitted.
        class StyleMixedListsRule < Base
          code "STANDOC_48"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_list(context.root) do |list, kind|
              nested_kind = offending_nested_kind(list, kind)
              next unless nested_kind

              issues << build_issue(
                location: model_location(list),
                params: ["mixed lists: #{nested_kind} list nested in " \
                         "#{kind} list (House Style forbids mixed lists)"]
              )
            end
            issues
          end

          private

          # Yield every list in the document with its kind (:ordered or
          # :unordered). OrderedList subclasses UnorderedList in the model,
          # so the kind is resolved by exact type, not by is_a? alone.
          def each_list(root)
            return enum_for(__method__, root) unless block_given?

            each_instance_of(root, Metanorma::Document::Components::Lists::UnorderedList) do |list|
              kind = list.is_a?(Metanorma::Document::Components::Lists::OrderedList) ? :ordered : :unordered
              yield(list, kind)
            end
          end

          def offending_nested_kind(list, kind)
            items = Array(list.listitem) if list.class.method_defined?(:listitem)
            return nil if items.nil? || items.empty?

            nested_attr = kind == :ordered ? :unordered_lists : :ordered_lists
            nested = items.any? do |item|
              item.class.method_defined?(nested_attr) &&
                !Array(item.public_send(nested_attr)).empty?
            end
            return nil unless nested

            nested_attr.to_s.delete_suffix("_lists")
          end
        end
      end
    end
  end
end
