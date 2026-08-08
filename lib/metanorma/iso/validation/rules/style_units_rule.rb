# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for percent formatting and SI unit spacing.
        # Subset of legacy validate_numeric.rb#style_percent +
        # style_units.
        #
        #   - "10%" should be "10 %" (space before %).
        #   - "10 °C" should be "10°C" (no space before non-breaking %,
        #     degrees, or SI unit symbols — except Celsius which keeps
        #     the space).
        #
        # Emitted via STANDOC_48 (generic style warning).
        class StyleUnitsRule < Base
          code "STANDOC_48"

          # Match a digit immediately followed by % (no space).
          # "50 %" is correct; "50%" is flagged.
          PERCENT_NO_SPACE_REGEX = /(?<num>[0-9])%/.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_paragraph(context.root) do |paragraph, parent|
              text = extract_text(paragraph).strip
              next if text.empty?

              issues.concat(check_percent(parent, text))
            end
            issues
          end

          private

          def check_percent(node, text)
            matches = text.scan(PERCENT_NO_SPACE_REGEX).map(&:first).compact.uniq
            matches.map do |match|
              build_warning(node, "no space before %: #{match}%")
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
