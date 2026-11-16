# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for the dotted lowercase forms "a.c.", "d.c."
        # and "r.f." (ISO House Style: write AC/DC undotted -- as
        # adjectives, or spelled out as nouns; "r.f." is obsolete -- use
        # "RF" or "radio-frequency"). The uppercase dotted forms are not
        # flagged (the patterns are case-sensitive) to keep national
        # usage such as "Washington, D.C." out of scope.
        class StyleAcDcRfRule < StyleRule
          code "ISO_67"

          policy category: "Abbreviated terms > Alternating current, direct current and radio frequency",
                 rule: "use 'AC'/'DC' as adjectives; 'r.f.' is obsolete — use 'RF' or 'radio-frequency'",
                 source: :house_style, mn_category: :style

          AC_DC_RF = {
            /\ba\.c\./ =>
              "style: 'a.c.' (use 'AC' as an adjective, or 'alternating " \
              "current' as a noun)",
            /\bd\.c\./ =>
              "style: 'd.c.' (use 'DC' as an adjective, or 'direct " \
              "current' as a noun)",
            /\br\.f\./ =>
              "style: 'r.f.' obsolete (use 'RF' or 'radio-frequency')"
          }.freeze

          def scan_text(node, text)
            AC_DC_RF.filter_map do |regex, label|
              next unless text.match?(regex)

              build_warning(node, label)
            end
          end
        end
      end
    end
  end
end
