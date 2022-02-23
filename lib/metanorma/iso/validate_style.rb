require "metanorma-standoc"
require "nokogiri"
require "tokenizer"

module Metanorma
  module ISO
    class Converter < Standoc::Converter
      def extract_text(node)
        return "" if node.nil?

        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath("//link | //locality | //localityStack").each(&:remove)
        ret = ""
        node1.traverse { |x| ret += x.text if x.text? }
        HTMLEntities.new.decode(ret)
      end

      # ISO/IEC DIR 2, 12.2
      def foreword_style(node)
        return if @novalid

        style_no_guidance(node, extract_text(node), "Foreword")
      end

      # ISO/IEC DIR 2, 14.2
      def scope_style(node)
        return if @novalid

        style_no_guidance(node, extract_text(node), "Scope")
      end

      # ISO/IEC DIR 2, 13.2
      def introduction_style(node)
        return if @novalid

        r = requirement_check(extract_text(node))
        style_warning(node, "Introduction may contain requirement", r) if r
      end

      # ISO/IEC DIR 2, 16.5.6
      def definition_style(node)
        return if @novalid

        r = requirement_check(extract_text(node))
        style_warning(node, "Definition may contain requirement", r) if r
      end

      # ISO/IEC DIR 2, 16.5.7
      # ISO/IEC DIR 2, 25.5
      def example_style(node)
        return if @novalid

        style_no_guidance(node, extract_text(node), "Example")
        style(node, extract_text(node))
      end

      # ISO/IEC DIR 2, 24.5
      def note_style(node)
        return if @novalid

        style_no_guidance(node, extract_text(node), "Note")
        style(node, extract_text(node))
      end

      # ISO/IEC DIR 2, 26.5
      def footnote_style(node)
        return if @novalid

        style_no_guidance(node, extract_text(node), "Footnote")
        style(node, extract_text(node))
      end

      def style_regex(regex, warning, n, text)
        (m = regex.match(text)) && style_warning(n, warning, m[:num])
      end

      # style check with a regex on a token
      # and a negative match on its preceding token
      def style_two_regex_not_prev(n, text, regex, re_prev, warning)
        return if text.nil?

        arr = Tokenizer::WhitespaceTokenizer.new.tokenize(text)
        arr.each_index do |i|
          m = regex.match arr[i]
          m_prev = i.zero? ? nil : re_prev.match(arr[i - 1])
          if !m.nil? && m_prev.nil?
            style_warning(n, warning, m[:num])
          end
        end
      end

      def style(node, text)
        return if @novalid

        style_number(node, text)
        style_percent(node, text)
        style_abbrev(node, text)
        style_units(node, text)
        style_punct(node, text)
      end

      # ISO/IEC DIR 2, 9.1
      # ISO/IEC DIR 2, Table B.1
      def style_number(node, text)
        style_two_regex_not_prev(
          node, text, /^(?<num>-?[0-9]{4,}[,0-9]*)\Z/,
          %r{\b(ISO|IEC|IEEE/|(in|January|February|March|April|May|June|August|September|October|November|December)\b)\Z},
          "number not broken up in threes"
        )
        style_regex(/\b(?<num>[0-9]+\.[0-9]+)/i,
                    "possible decimal point", node, text)
        style_regex(/\b(?<num>billions?)\b/i,
                    "ambiguous number", node, text)
      end

      # ISO/IEC DIR 2, 9.2.1
      def style_percent(node, text)
        style_regex(/\b(?<num>[0-9.,]+%)/,
                    "no space before percent sign", node, text)
        style_regex(/\b(?<num>[0-9.,]+ \u00b1 [0-9,.]+ %)/,
                    "unbracketed tolerance before percent sign", node, text)
      end

      # ISO/IEC DIR 2, 8.4
      # ISO/IEC DIR 2, 9.3
      def style_abbrev(node, text)
        style_regex(/(\A|\s)(?!e\.g\.|i\.e\.)
                    (?<num>[a-z]{1,2}\.([a-z]{1,2}|\.))\b/ix,
                    "no dots in abbreviations", node, text)
        style_regex(/\b(?<num>ppm)\b/i,
                    "language-specific abbreviation", node, text)
      end

      # leaving out as problematic: N J K C S T H h d B o E
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|Hz|MHz|Pa|hPa|kJ|"\
                "V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|"\
                "bit|kB|MB|Hart|nat|Sh|var)".freeze

      # ISO/IEC DIR 2, 9.3
      def style_units(node, text)
        style_regex(/\b(?<num>[0-9][0-9,]*\s+[\u00b0\u2032\u2033])/,
                    "space between number and degrees/minutes/seconds",
                    node, text)
        style_regex(/\b(?<num>[0-9][0-9,]*#{SI_UNIT})\b/o,
                    "no space between number and SI unit", node, text)
        style_non_std_units(node, text)
      end

      NONSTD_UNITS = {
        sec: "s", mins: "min", hrs: "h", hr: "h", cc: "cm^3",
        lit: "l", amp: "A", amps: "A", rpm: "r/min"
      }.freeze

      # ISO/IEC DIR 2, 9.3
      def style_non_std_units(node, text)
        NONSTD_UNITS.each do |k, v|
          style_regex(/\b(?<num>[0-9][0-9,]*\s+#{k})\b/,
                      "non-standard unit (should be #{v})", node, text)
        end
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-and
      def style_punct(node, text)
        style_regex(/\b(?<num>and\/?or)\b/i,
                    "Use 'either x or y, or both'", node, text)
      end

      def style_warning(node, msg, text = nil)
        return if @novalid

        w = msg
        w += ": #{text}" if text
        @log.add("Style", node, w)
      end
    end
  end
end
