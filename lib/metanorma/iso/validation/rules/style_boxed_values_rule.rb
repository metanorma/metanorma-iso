# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: boxed values — a value enclosed in square
        # brackets, e.g. "[13,0 %]" or "[10 mm]" — are avoided in body
        # text (ISO House Style): state the plain value instead.
        #
        # Citation callouts ("[1]", "[2]") are digits-only and are not
        # flagged: a bracket only counts as a boxed value when it carries
        # a number with a decimal part, a unit or a percent sign. Stem,
        # formula and sourcecode blocks are exempt.
        class StyleBoxedValuesRule < StyleRule
          policy category: "Additional elements > Boxed values",
                 rule: "avoid boxed values in body text; state the plain value",
                 source: :house_style, mn_category: :style

          # Bracketed number with a decimal part, a unit or a percent
          # sign. A bare integer ("[1]") is a citation callout, not a
          # boxed value.
          BOXED_VALUE_REGEX = %r{
            \[\s*\d+(?:[.,]\d+)?\s*(?:%|[a-zA-Z][a-zA-Z0-9/^·\-]*\b)\s*\]
          }x.freeze

          EXEMPT_PARAGRAPH_TYPES = %w[stem formula sourcecode].freeze

          def check(context)
            issues = []
            each_paragraph_with_parent(context.root) do |paragraph, parent|
              next if exempt_container?(parent)
              next if exempt_paragraph_type?(paragraph)

              text = extract_text(paragraph).strip
              next if text.empty?

              issues.concat(scan_text(parent, text))
            end
            issues
          end

          def scan_text(node, text)
            findings_for_matches(node, text, BOXED_VALUE_REGEX,
                                 "boxed value: avoid boxed values ('%s'); " \
                                 "state the plain value")
          end

          private

          def exempt_container?(node)
            node.is_a?(Metanorma::Document::Components::AncillaryBlocks::FormulaBlock) ||
              node.is_a?(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock)
          end

          def exempt_paragraph_type?(paragraph)
            return false unless paragraph.class.method_defined?(:type_attr)

            EXEMPT_PARAGRAPH_TYPES.include?(paragraph.type_attr.to_s)
          end
        end
      end
    end
  end
end
