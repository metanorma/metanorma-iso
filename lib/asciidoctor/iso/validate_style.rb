require "metanorma-standoc"
require "nokogiri"
require "tokenizer"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def extract_text(node)
        return "" if node.nil?
        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath("//link | //locality | //localityStack").each(&:remove)
        ret = ""
        node1.traverse { |x| ret += x.text if x.text? }
        ret
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

      def style_regex(re, warning, n, text)
        (m = re.match(text)) && style_warning(n, warning, m[:num])
      end

      # style check with a regex on a token
      # and a negative match on its preceding token
      def style_two_regex_not_prev(n, text, re, re_prev, warning)
        return if text.nil?
        arr = Tokenizer::WhitespaceTokenizer.new.tokenize(text)
        arr.each_index do |i|
          m = re.match arr[i]
          m_prev = i.zero? ? nil : re_prev.match(arr[i - 1])
          if !m.nil? && m_prev.nil?
            style_warning(n, warning, m[:num])
          end
        end
      end

      def style(n, t)
        return if @novalid
        style_number(n, t)
        style_percent(n, t)
        style_abbrev(n, t)
        style_units(n, t)
      end

      # ISO/IEC DIR 2, 9.1
      # ISO/IEC DIR 2, Table B.1
      def style_number(n, t)
        style_two_regex_not_prev(
          n, t, /^(?<num>-?[0-9]{4,}[,0-9]*)$/,
          %r{\b(ISO|IEC|IEEE/|(in|January|February|March|April|May|June|August|September|October|November|December)\b)$},
          "number not broken up in threes")
        style_regex(/\b(?<num>[0-9]+\.[0-9]+)/i,
                    "possible decimal point", n, t)
        style_regex(/\b(?<num>billion[s]?)\b/i,
                    "ambiguous number", n, t)
      end

      # ISO/IEC DIR 2, 9.2.1
      def style_percent(n, t)
        style_regex(/\b(?<num>[0-9.,]+%)/,
                    "no space before percent sign", n, t)
        style_regex(/\b(?<num>[0-9.,]+ \u00b1 [0-9,.]+ %)/,
                    "unbracketed tolerance before percent sign", n, t)
      end

      # ISO/IEC DIR 2, 8.4
      # ISO/IEC DIR 2, 9.3
      def style_abbrev(n, t)
        style_regex(/(^|\s)(?!e\.g\.|i\.e\.)
                    (?<num>[a-z]{1,2}\.([a-z]{1,2}|\.))\b/ix,
                      "no dots in abbreviations", n, t)
        style_regex(/\b(?<num>ppm)\b/i,
                    "language-specific abbreviation", n, t)
      end

      # leaving out as problematic: N J K C S T H h d B o E
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|Hz|MHz|Pa|hPa|kJ|"\
        "V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|"\
        "bit|kB|MB|Hart|nat|Sh|var)".freeze

      # ISO/IEC DIR 2, 9.3
      def style_units(n, t)
        style_regex(/\b(?<num>[0-9][0-9,]*\s+[\u00b0\u2032\u2033])/,
                    "space between number and degrees/minutes/seconds", n, t)
        style_regex(/\b(?<num>[0-9][0-9,]*#{SI_UNIT})\b/,
                    "no space between number and SI unit", n, t)
        style_non_std_units(n, t)
      end

      NONSTD_UNITS = {
        "sec": "s", "mins": "min", "hrs": "h", "hr": "h", "cc": "cm^3",
        "lit": "l", "amp": "A", "amps": "A", "rpm": "r/min"
      }.freeze

      # ISO/IEC DIR 2, 9.3
      def style_non_std_units(n, t)
        NONSTD_UNITS.each do |k, v|
          style_regex(/\b(?<num>[0-9][0-9,]*\s+#{k})\b/,
                      "non-standard unit (should be #{v})", n, t)
        end
      end
    end
  end
end
