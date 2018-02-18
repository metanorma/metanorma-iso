require "asciidoctor/iso/utils"
require "nokogiri"
require "pp"

module Asciidoctor
  module ISO
    module Validate
      def foreword_style(node, text)
        style_no_guidance(node, text, "Foreword")
      end

      def scope_style(node, text)
        style_no_guidance(node, text, "Scope")
      end

      def introduction_style(node, text)
        r = requirement(text)
        style_warning(node, "Introduction may contain requirement", r) if r
      end

      def termexample_style(node, text)
        style_no_guidance(node, text, "Term Example")
        style(node, text)
      end

      def note_style(node, text)
        style_no_guidance(node, text, "Note")
        style(node, text)
      end

      def footnote_style(node, text)
        style_no_guidance(node, text, "Footnote")
        style(node, text)
      end

      def style_warning(node, msg, text)
        w = "ISO style: WARNING (#{Utils::current_location(node)}): #{msg}"
        w += ": #{text}" if text
        warn w
      end

      def style_regex(re, warning, n, text)
        (m = re.match(text)) && style_warning(n, warning, m[:num])
      end

      # style check with a regex on a token
      # and a negative match on its preceding token
      def style_two_regex_not_prev(n, text, re, re_prev, warning)
        return if text.nil?
        text.split(/\W+/).each_index do |i|
          next if i.zero?
          m = re.match text[i]
          m_prev = re_prev.match text[i - 1]
          if !m.nil? && m_prev.nil?
            style_warning(n, warning, m[:num])
          end
        end
      end

      # leaving out as problematic: N J K C S T H h d B o E
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|Hz|MHz|Pa|hPa|kJ|"\
        "V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|"\
        "bit|kB|MB|Hart|nat|Sh|var)".freeze

      def style(n, t)
        style_two_regex_not_prev(n, t, /^(?<num>[0-9]{4,})$/,
                                 %r{(\bISO|\bIEC|\bIEEE/)$},
                                 "number not broken up in threes")
        style_regex(/\b(?<num>[0-9]+\.[0-9]+)/,
                    "possible decimal point", n, t)
        style_regex(/\b(?<num>[0-9.,]+%)/,
                    "no space before percent sign", n, t)
        style_regex(/\b(?<num>[0-9.,]+ \u00b1 [0-9,.]+ %)/,
                    "unbracketed tolerance before percent sign", n, t)
        style_regex(/(^|\s)(?<=e\.g\.|i\.e\.)
                    (?<num>[a-z]{1,2}\.([a-z]{1,2}|\.))\b/ix,
                      "no dots in abbreviations", n, t)
        style_regex(/\b(?<num>[0-9][0-9,]*\s+[\u00b0\u2032\u2033])/,
                    "space between number and degrees/minutes/seconds", n, t)
        style_regex(/\b(?<num>[0-9][0-9,]*#{SI_UNIT})\b/,
                    "no space between number and SI unit", n, t)
        style_regex(/\b(?<num>ppm)\b/i,
                    "language-specific abbreviation", n, t)
        style_regex(/\b(?<num>billion[s]?)\b/i,
                    "ambiguous number", n, t)
        style_non_std_units(n, t)
      end

      NONSTD_UNITS = {
        "sec": "s", "mins": "min", "hrs": "h", "hr": "h", "cc": "cm^3",
        "lit": "l", "amp": "A", "amps": "A", "rpm": "r/min" }.freeze

      def style_non_std_units(n, t)
        NONSTD_UNITS.each do |k, v|
          style_regex(/\b(?<num>[0-9][0-9,]*\s+#{k})\b/,
                      "non-standard unit (should be #{v})", n, t)
        end
      end
    end
  end
end
