# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "ca." and "c.f." (ISO House Style: write
        # "approximately"; "c.f." with two periods is banned -- use "cf."
        # or "see"). "cf." without internal periods is correct and is
        # not flagged; nor is "e.g."/"i.e." (StyleEgEtcRule).
        class StyleCaCfRule < StyleRule
          policy category: ["Abbreviated terms > ca. (approximately)",
                            "Abbreviated terms > c.f. (confer)"],
                 rule: "do not use 'ca.' (write 'approximately'); do not use 'c.f.' (write 'see')",
                 source: :house_style, mn_category: :style

          CA_CF = {
            /\bca\./ => "style: 'ca.' (use 'approximately')",
            /\bc\.f\./i => "style: 'c.f.' (use 'cf.' or 'see')"
          }.freeze

          def scan_text(node, text)
            CA_CF.filter_map do |regex, label|
              next unless text.match?(regex)

              build_warning(node, label)
            end
          end
        end
      end
    end
  end
end
