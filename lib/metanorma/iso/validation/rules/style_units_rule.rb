# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for percent formatting. Subset of legacy
        # validate_numeric.rb#style_percent.
        #
        #   - "10%" should be "10 %" (space before %).
        #
        # SI unit spacing and degree symbol checks remain in legacy form
        # pending inline-text-walking helpers.
        class StyleUnitsRule < StyleRule
          # Match a digit immediately followed by % (no space).
          # "50 %" is correct; "50%" is flagged.
          PERCENT_NO_SPACE_REGEX = /([0-9])%/.freeze

          def scan_text(node, text)
            findings_for_matches(node, text, PERCENT_NO_SPACE_REGEX,
                                 "no space before %%: %s%%")
          end
        end
      end
    end
  end
end
