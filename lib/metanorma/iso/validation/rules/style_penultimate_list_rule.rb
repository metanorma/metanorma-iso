# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: in lists of two or more items, the penultimate
        # item omits the trailing "and"/"or" (ISO House Style). The
        # conjunction is permitted only where its omission would create
        # ambiguity.
        class StylePenultimateListRule < Base
          code "ISO_108"

          policy category: "Lists",
                 rule: "the penultimate list item omits 'and'/'or', except to avoid ambiguity",
                 source: :house_style, mn_category: :style

          # Word-boundary "and"/"or" at the end of the item text,
          # tolerating terminal punctuation after the conjunction.
          TRAILING_AND_OR_REGEX = /(?:\s|\A)(and|or)\s*[.,;:]?\s*\z/i.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_list(context.root) do |list|
              item_text = penultimate_item_text(list)
              next unless item_text

              conjunction = conjunction_at_end(item_text)
              next unless conjunction

              issues << build_issue(
                location: model_location(list),
                params: ["penultimate list item ends with '#{conjunction}': " \
                         "the penultimate item omits and/or unless needed " \
                         "to avoid ambiguity"]
              )
            end
            issues
          end

          private

          def each_list(root)
            return enum_for(__method__, root) unless block_given?

            each_instance_of(root, Metanorma::Document::Components::Lists::List) do |list|
              yield(list)
            end
          end

          def penultimate_item_text(list)
            items = Array(list.listitem) if list.class.method_defined?(:listitem)
            return nil if items.nil? || items.size < 2

            extract_text(items[-2]).strip
          end

          def conjunction_at_end(item_text)
            item_text.match(TRAILING_AND_OR_REGEX)&.[](1)&.downcase
          end
        end
      end
    end
  end
end
