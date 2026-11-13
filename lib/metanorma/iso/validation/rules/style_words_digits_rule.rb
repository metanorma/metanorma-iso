# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for the numbers one to nine written as digits
        # in prose (ISO House Style): "three samples", not "3 samples".
        #
        # This is the noisiest word/number rule, so it fails open: a
        # digit is flagged ONLY when none of the House Style's
        # digit-licensing contexts applies:
        #
        #   - followed by a unit token ("3 mm", "3mm"), a spelled-out
        #     time quantity ("3 days"), a percent ("5 %", "5 percent"),
        #     a currency word, a month name (a date), a single-letter
        #     designation ("3D"), thousands separator ("1,000") or a
        #     decimal point ("3.5");
        #   - a comparison ("8 votes to 6", "3 to 5", a "3-5" range);
        #   - preceded by a reference token (Clause, Table, Figure,
        #     ISO, annex, part, step, ...), a month name, a currency
        #     symbol, an opening parenthesis, or a hyphen/dash (the
        #     tail of a range or a part suffix "10303-1");
        #   - attached to a letter (letter-digit codes "M3", "A4");
        #   - starting a sentence (StyleSentenceStartNumberRule owns
        #     that case).
        #
        # Multi-digit numbers are out of scope by construction: the
        # scan matches only standalone digits 1-9.
        class StyleWordsDigitsRule < StyleRule
          code "ISO_121"

          policy category: "Numbers, values and dates > General",
                 rule: "write the numbers one to nine as words in prose " \
                       "('three samples'); digits are reserved for units, " \
                       "references, dates and quantities",
                 source: :house_style, mn_category: :style

          # A single digit 1-9 standing alone: no neighbouring digit or
          # decimal point, not attached to a letter (letter-digit codes
          # such as "M3" and "A4" are out of scope).
          SINGLE_DIGIT_REGEX = /(?<![\d.A-Za-z])([1-9])(?!\d)/.freeze

          DIGIT_MESSAGE =
            "style: digit '%s' in prose (write the numbers one to " \
            "nine as words)".freeze

          # Unit tokens that license a digit, symbol-spaced or not.
          # "in" (inch) is deliberately absent: it reads as the English
          # word in prose ("3 in total") and its flag risk outweighs
          # the exemption value.
          UNIT_TOKENS = %w[
            % µm mm cm dm m km ft yd s ms µs ns min h d t kHz MHz
            GHz THz Hz kPa MPa GPa Pa mbar bar mol mL ml l L g kg mg
            µg °C N kN MN A mA V mV W mW kW J kJ
          ].freeze

          UNIT_GROUP = UNIT_TOKENS.map { |u| Regexp.escape(u) }.join("|").freeze

          UNIT_FOLLOW_REGEX = /\A\s?(?:#{UNIT_GROUP})(?![a-z])/i.freeze

          MONTHS = %w[
            january february march april may june july august september
            october november december
          ].freeze

          MONTHS_GROUP = MONTHS.join("|").freeze

          MONTH_FOLLOW_REGEX = /\A\s?(?:#{MONTHS_GROUP})\b/i.freeze
          MONTH_BEFORE_REGEX = /\b(?:#{MONTHS_GROUP})\s+\z/i.freeze

          # Spelled-out time quantities ("3 days"): quantities take
          # digits, so they pass.
          TIME_WORDS_FOLLOW_REGEX =
            /\A\s?(?:years?|months?|weeks?|days?|hours?|minutes?|seconds?|decades|centuries)\b/i.freeze

          PERCENT_FOLLOW_REGEX = /\A\s?(?:%|per\s?cent(?:um)?)/i.freeze

          CURRENCY_FOLLOW_REGEX =
            /\A\s?(?:euros?|dollars?|pounds?|cents?|usd|eur|gbp|jpy|cny)\b/i.freeze

          CURRENCY_BEFORE_REGEX = /[€$£¥]\z/.freeze

          # Single-letter designations ("3D", "4K").
          SINGLE_LETTER_SUFFIX_REGEX = /\A\s?[a-zA-Z](?![a-z])/i.freeze

          RANGE_FOLLOW_REGEX = /\A\s?[–—-]\s?\d/.freeze
          DASH_BEFORE_REGEX = /[–—-]\s?\z/.freeze

          COMPARISON_DIRECT_REGEX = /\A\s?to\s+[1-9](?!\d)/i.freeze
          COMPARISON_SPAN_REGEX = /\A\s?[a-z]+\s+to\s+[1-9]/i.freeze
          COMPARISON_BEFORE_REGEX = /\bto\s+\z/i.freeze

          THOUSANDS_FOLLOW_REGEX = /\A,\d/.freeze
          DECIMAL_FOLLOW_REGEX = /\A\.\d/.freeze
          PAREN_BEFORE_REGEX = /\(\s*\z/.freeze

          # Reference and designation tokens that license a digit
          # ("see Clause 3", "Table 4", "aged 6", "part 2").
          REFERENCE_TOKENS_BEFORE_REGEX =
            /(?:clause|table|figure|fig\.?|equation|eq\.?|formula|annex|iso|iec|aged|no\.?|nos\.?|part|step|version|edition|type|class|grade|size|page|item|see)\s+\z/i.freeze

          # House Style licenses digits in all of these contexts; the
          # rule fails open whenever any applies. FOLLOW regexes anchor
          # at the digit's right edge; BEFORE regexes at its left edge.
          FOLLOW_EXEMPTION_REGEXES = [
            UNIT_FOLLOW_REGEX,
            MONTH_FOLLOW_REGEX,
            TIME_WORDS_FOLLOW_REGEX,
            PERCENT_FOLLOW_REGEX,
            CURRENCY_FOLLOW_REGEX,
            SINGLE_LETTER_SUFFIX_REGEX,
            RANGE_FOLLOW_REGEX,
            COMPARISON_DIRECT_REGEX,
            COMPARISON_SPAN_REGEX,
            THOUSANDS_FOLLOW_REGEX,
            DECIMAL_FOLLOW_REGEX,
          ].freeze

          BEFORE_EXEMPTION_REGEXES = [
            MONTH_BEFORE_REGEX,
            CURRENCY_BEFORE_REGEX,
            REFERENCE_TOKENS_BEFORE_REGEX,
            COMPARISON_BEFORE_REGEX,
            DASH_BEFORE_REGEX,
            PAREN_BEFORE_REGEX,
          ].freeze

          def prose_exclusions
            super + %i(json_type json_content)
          end

          def scan_text(node, text)
            unlicensed_digits(text.to_s).uniq.map do |digit|
              build_warning(node, format(DIGIT_MESSAGE, digit))
            end
          end

          private

          # Single digits 1-9 in prose that no digit-licensing context
          # covers.
          def unlicensed_digits(str)
            starts = Metanorma::Iso::Validation::SentenceScan
              .sentences(str).map(&:start)
            flagged = []
            str.to_enum(:scan, SINGLE_DIGIT_REGEX).each do
              match = Regexp.last_match
              next if starts.include?(match.begin(0))
              next if exempt_by_context?(str, match)

              flagged << match[0]
            end
            flagged
          end

          def exempt_by_context?(str, match)
            before = str[[match.begin(0) - 24, 0].max...match.begin(0)]
            after = str[match.end(0), 24]

            FOLLOW_EXEMPTION_REGEXES.any? { |regex| regex.match?(after) } ||
              BEFORE_EXEMPTION_REGEXES.any? { |regex| regex.match?(before) }
          end
        end
      end
    end
  end
end
