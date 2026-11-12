# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for quantity ranges (ISO House Style): ranges
        # between numbers carrying units are written with "to", not a
        # closed-up hyphen or an en dash, because the dash is read as
        # a minus sign.
        #
        #   "5-10 mm"        → "5 mm to 10 mm"
        #   "10 mm - 20 mm"  → "10 mm to 20 mm"
        #   "100–200 kg"     → "100 kg to 200 kg"
        #
        # Only spans where a unit word FOLLOWS the second number are
        # flagged: date ranges ("10-15 March", "2020-2030") and
        # century ranges are StyleDateDurationRule's scope, and
        # closed-up page ranges ("pp. 45-49") stay permitted. The unit
        # set is a closed, case-sensitive list of common unit symbols
        # (plus "%"), which keeps ordinary identifier hyphens
        # ("ISO 10303-11", "3166-1 alpha-2") unflagged. Digit-grouped
        # amounts ("1 000-2 000 mm") are not matched, by design.
        class StyleEnDashRangesRule < StyleRule
          policy category: "Numbers, values and dates > Numbers",
                 rule: "use 'to' between digits in quantity ranges ('5 mm to 10 mm')",
                 source: :house_style, mn_category: :style

          UNITS = %w[
            mm cm km m um nm g mg kg t s ms us ns min h
            Hz kHz MHz GHz Pa kPa MPa GPa N kN MN A mA V mV kV
            W mW kW MW J kJ MJ Wh kWh dB dBm mol cd lx lm Bq Gy Sv kat
            bar % °C
          ].freeze

          UNIT_ALT = UNITS.map { |u| Regexp.escape(u) }.join("|").freeze

          # One unit word, e.g. " mm", " %" or " °C".
          UNIT_WORD = /\s+(?:#{UNIT_ALT})(?![a-zA-Z])/.freeze

          # "10 mm to 20 mm" second half: number + unit.
          NUMBER_UNIT_BODY = /\d+(?:[.,]\d+)?#{UNIT_WORD}/.freeze

          # "5-10 mm", "100–200 kg" — dash between the numbers, one
          # unit word after the second number.
          CLOSED_RANGE_REGEX =
            /\b\d+(?:[.,]\d+)?\s*[-–]\s*#{NUMBER_UNIT_BODY}/.freeze

          # "10 mm - 20 mm" — a unit on both sides of the dash.
          SPACED_UNIT_RANGE_REGEX =
            /\b\d+(?:[.,]\d+)?#{UNIT_WORD}\s*[-–]\s*#{NUMBER_UNIT_BODY}/.freeze

          LABEL = "quantity range: use 'to', e.g. '10 mm to 20 mm', " \
                  "not '%s'".freeze

          def scan_text(node, text)
            findings_for_matches(node, text, SPACED_UNIT_RANGE_REGEX, LABEL) +
              findings_for_matches(node, text, CLOSED_RANGE_REGEX, LABEL)
          end
        end
      end
    end
  end
end
