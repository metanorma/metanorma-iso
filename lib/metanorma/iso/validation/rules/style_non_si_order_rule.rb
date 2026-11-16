# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: when a quantity carries both an SI and a non-SI
        # value, the SI value comes first and the non-SI value follows
        # in parentheses: "5,6 km (3,5 miles)" (ISO House Style,
        # Quantities and units). A parenthetical that carries the ONLY
        # value+unit of its statement makes the non-SI value primary --
        # the wrong order.
        #
        # The flagged shape is the clean one, and deliberately narrow:
        # a parenthetical whose content is exactly a number and a
        # non-SI unit token, while the text immediately before the open
        # parenthesis carries no unit at all. Anything else passes,
        # including:
        #
        # - "5 km (3,5 miles)": the SI value is primary (correct);
        # - "450 hp (336 kW)": a unit precedes the parenthesis, so the
        #   statement already carries a primary value (the ordering
        #   inside that pair is not judged by this rule);
        # - "(5 km)" and "(3)": parenthetical units outside the non-SI
        #   list and bare digits (citation callouts) pass;
        # - "(see Table 3)": content that is not exactly value+unit.
        #
        # Units are detected against closed token lists, anchored to a
        # preceding number so that ordinary words never read as units
        # ("in the range", "A 5 m rope"). Symbol units match
        # case-sensitively ("5 KN" is kilonewtons, not knots); word
        # units match case-insensitively.
        class StyleNonSiOrderRule < StyleRule
          code "ISO_146"

          policy category: "Quantities and units > non-SI units",
                 rule: "the SI-equivalent value comes first and the non-SI " \
                       "value follows in parentheses: 5,6 km (3,5 miles)",
                 source: :house_style, mn_category: :style

          # Common non-SI units: closed lists. Symbol entries are
          # case-sensitive, word entries case-insensitive.
          NON_SI_SYMBOL_UNITS = [
            "°F", "mph", "psi", "hp", "kcal", "cal", "knots", "knot",
            "kn", "lbs", "lb", "oz", "yd", "mi", "in", "ft", "bar",
            "miles", "mile",
          ].freeze
          NON_SI_WORD_UNITS = ["miles per hour", "mile per hour"].freeze

          # SI (and SI-derived) units: a preceding value carrying one of
          # these means the statement already has its SI value. Closed
          # list; case-sensitive.
          SI_SYMBOL_UNITS = [
            "GPa", "MPa", "kPa", "Pa", "MN", "kN", "N", "MJ", "kJ", "J",
            "GW", "MW", "kW", "W", "MHz", "kHz", "Hz", "kV", "mV", "V",
            "km/h", "m/s", "km", "cm", "mm", "nm", "kg", "mg", "g",
            "mol", "ohm", "cd", "ms", "s", "m", "A", "K",
          ].freeze

          NON_SI_SYMBOL_PATTERN = NON_SI_SYMBOL_UNITS
            .sort_by { |u| -u.length }.map { |u| Regexp.escape(u) }.join("|")
            .freeze
          NON_SI_WORD_PATTERN = NON_SI_WORD_UNITS
            .sort_by { |u| -u.length }.map { |u| Regexp.escape(u) }.join("|")
            .freeze
          SI_SYMBOL_PATTERN = SI_SYMBOL_UNITS
            .sort_by { |u| -u.length }.map { |u| Regexp.escape(u) }.join("|")
            .freeze

          # A parenthetical whose content is exactly a value and a
          # non-SI unit (word forms case-insensitive).
          PAREN_REGEX = /\(([^()]{1,80})\)/.freeze
          VALUE_UNIT_REGEX =
            /\A\s*\d+(?:[.,]\d+)?\s+(?:#{NON_SI_SYMBOL_PATTERN})\s*\z/.freeze
          VALUE_UNIT_WORD_REGEX =
            /\A\s*\d+(?:[.,]\d+)?\s+(?:#{NON_SI_WORD_PATTERN})\s*\z/i.freeze

          LABEL = "style: the non-SI value '(%s)' has no preceding SI " \
                  "value; state the SI value first and the non-SI value " \
                  "in parentheses".freeze

          def scan_text(node, text)
            issues = []
            text.to_enum(:scan, PAREN_REGEX).each do
              match = Regexp.last_match
              content = match[1]
              next unless value_unit?(content)
              next if unit_carrier?(preceding_value_text(text, match.begin(0)))

              issues << build_warning(node, format(LABEL, content))
            end
            issues
          end

          private

          # A parenthetical carrying the non-SI value.
          def value_unit?(content)
            content.match?(VALUE_UNIT_REGEX) ||
              content.match?(VALUE_UNIT_WORD_REGEX)
          end

          # SI and non-SI alike anchored to a preceding number: a bare
          # word never reads as a unit ("in the range"). Case-sensitive
          # on symbol units; word forms match case-insensitively.
          def unit_carrier?(window)
            number = /\d(?:[\d.,]*\d)?\s*/
            window.match?(/#{number}(?:#{SI_SYMBOL_PATTERN})(?![A-Za-z])/) ||
              window.match?(
                /#{number}(?:#{NON_SI_SYMBOL_PATTERN})(?![A-Za-z])/
              ) ||
              window.match?(/#{number}(?:#{NON_SI_WORD_PATTERN})/i)
          end

          # The text immediately before the open parenthesis: back to
          # the previous sentence boundary, capped at 120 characters,
          # with earlier parentheticals blanked out -- a preceding
          # parenthetical is a value in the wrong position, not a
          # primary value that licenses the next one.
          def preceding_value_text(text, index)
            window = text[0...index].to_s.gsub(PAREN_REGEX, " ")
            window = window.split(/(?<=[.;:!?])\s/).last || ""
            window[-120..] || window
          end
        end
      end
    end
  end
end
