# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for number formatting in text content. Covers a
        # subset of the legacy validate_numeric.rb checks:
        #
        #   - Decimal points: numbers containing "." should be marked up
        #     with stem:[] (ISO/IEC DIR 2, 9.1).
        #   - Hyphen instead of minus sign (U+2212).
        #
        # Emitted via STANDOC_48 (generic style warning). Subscript depth
        # and SI unit spacing remain in legacy form (require inline-element
        # walking not yet ported to the model).
        class StyleNumberRule < Base
          code "STANDOC_48"

          DECIMAL_POINT_REGEX = /(?:^|\p{Zs})(?<num>[0-9]+\.[0-9]+)(?!\.[0-9])/i.freeze
          HYPHEN_MINUS_REGEX = /(?:^|\p{Zs})(?<num>-[0-9][0-9,.]*)/i.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_paragraph(context.root) do |paragraph, parent|
              text = extract_text(paragraph).strip
              next if text.empty?

              issues.concat(check_decimals(parent, text))
              issues.concat(check_hyphen_minus(parent, text))
            end
            issues
          end

          private

          def check_decimals(node, text)
            matches = text.scan(DECIMAL_POINT_REGEX).map(&:first).compact.uniq
            matches.map do |match|
              build_warning(node, "possible decimal point: mark up numbers with stem:[]: #{match}")
            end
          end

          def check_hyphen_minus(node, text)
            matches = text.scan(HYPHEN_MINUS_REGEX).map(&:first).compact.uniq
            matches.map do |match|
              build_warning(node, "hyphen instead of minus sign U+2212: #{match}")
            end
          end

          def build_warning(node, message)
            build_issue(location: model_location(node), params: [message])
          end
        end
      end
    end
  end
end
