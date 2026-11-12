# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: admonition boxes (the <admonition> element,
        # including Metanorma's box blocks) are avoided in ISO
        # documents — boxes cannot be cross-referenced. Use a figure,
        # a table, or a separate subclause instead.
        #
        # Notes (<note> elements) are a different model class and are
        # never flagged; likewise examples. An <admonition> whose type
        # is "note" is exempt as well. This rule flags the admonition
        # element only — wherever it appears in the document.
        class StyleNoBoxesRule < StyleRule
          code "ISO_103"

          policy category: "Additional elements > Boxes",
                 rule: "boxes are discouraged — they cannot be cross-referenced; use a figure, a table or a separate subclause",
                 source: :house_style, mn_category: :style

          ADMONITION_CLASS =
            Metanorma::Document::Components::MultiParagraph::AdmonitionBlock

          LABEL = "admonition box: boxes cannot be cross-referenced; " \
                  "use a figure, a table, or a separate subclause".freeze

          def check(context)
            issues = []
            each_instance_of(context.root, ADMONITION_CLASS) do |admonition|
              next if exempt_type?(admonition)

              issues << build_warning(admonition, LABEL)
            end
            issues
          end

          private

          def exempt_type?(admonition)
            return false unless admonition.class.method_defined?(:type)

            admonition.type.to_s == "note"
          end
        end
      end
    end
  end
end
