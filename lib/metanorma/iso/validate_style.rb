require "metanorma-standoc"
require "nokogiri"
require "tokenizer"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def extract_text(node)
        node.nil? and return ""
        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath(".//link | .//locality | .//localityStack | .//stem")
          .each(&:remove)
        ret = ""
        node1.traverse { |x| ret += x.text if x.text? }
        HTMLEntities.new.decode(ret)
      end

      # ISO/IEC DIR 2, 12.2
      def foreword_style(node)
        @novalid and return
        style_no_guidance(node, extract_text(node), "Foreword")
      end

      # ISO/IEC DIR 2, 14.2
      def scope_style(node)
        @novalid and return
        style_no_guidance(node, extract_text(node), "Scope")
      end

      # ISO/IEC DIR 2, 13.2
      def introduction_style(node)
        @novalid and return
        r = requirement_check(extract_text(node))
        style_warning(node, "Introduction may contain requirement", r) if r
      end

      # ISO/IEC DIR 2, 16.5.6
      def definition_style(node)
        @novalid and return
        r = requirement_check(extract_text(node))
        style_warning(node, "Definition may contain requirement", r) if r
      end

      # ISO/IEC DIR 2, 16.5.7
      # ISO/IEC DIR 2, 25.5
      def example_style(node)
        @novalid and return
        style_no_guidance(node, extract_text(node), "Example")
        style(node, extract_text(node))
      end

      # ISO/IEC DIR 2, 24.5
      def note_style(node)
        @novalid and return
        style_no_guidance(node, extract_text(node), "Note")
        style(node, extract_text(node))
      end

      # ISO/IEC DIR 2, 26.5
      def footnote_style(node)
        @novalid and return
        style_no_guidance(node, extract_text(node), "Footnote")
        style(node, extract_text(node))
      end

      def style_regex(regex, warning, node, text)
        (m = regex.match(text)) && style_warning(node, warning, m[:num])
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
        @novalid and return
        @novalid_number or style_number(node, text)
        style_percent(node, text)
        style_abbrev(node, text)
        style_units(node, text)
        style_punct(node, text)
        style_subscript(node)
        style_ambig_words(node, text)
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-quantity
      def style_subscript(node)
        warning = "may contain nested subscripts (max 3 levels allowed)"
        node.xpath(".//sub[.//sub]").each do |x|
          style_warning(node, warning, x.to_xml)
        end
        node.xpath(".//m:msub[.//m:msub]", "m" => MATHML_NS).each do |x|
          style_warning(node, warning, x.to_xml)
        end
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-need
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-might
      def style_ambig_words(node, text)
        r = ambig_words_check(text) and
          style_warning(node, "may contain ambiguous provision", r)
        @lang == "en" and style_regex(/\b(?<num>billions?)\b/i,
                                      "ambiguous number", node, text)
      end

      # ISO/IEC DIR 2, 9.1
      # ISO/IEC DIR 2, Table B.1
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-n-numbers
      def style_number(node, text)
        style_number_grouping(node, text)
        style_regex(/(?:^|\p{Zs})(?<num>[0-9]+\.[0-9]+)(?!\.[0-9])/i,
                    "possible decimal point: mark up numbers with stem:[]", node, text)
        @lang == "en" and style_regex(/\b(?<num>billions?)\b/i,
                                      "ambiguous number", node, text)
        style_regex(/(?:^|\p{Zs})(?<num>-[0-9][0-9,.]*)/i,
                    "hyphen instead of minus sign U+2212", node, text)
        @novalid_number = true
      end

      def style_number_grouping(node, text)
        if @validate_years
          style_two_regex_not_prev(
            node, text, /^(?<num>-?[0-9]{4,}[,0-9]*)\Z/,
            %r{\b(ISO|IEC|IEEE|(in|January|February|March|April|May|June|August|September|October|November|December)\b)\Z},
            "number not broken up in threes: mark up numbers with stem:[]"
          )
        else
          style_two_regex_not_prev(
            node, text, /^(?<num>-?(?:[0-9]{5,}[,0-9]*|[03-9]\d\d\d|1[0-8]\d\d|2[1-9]\d\d|20[5-9]\d))\Z/,
            %r{\b(ISO|IEC|IEEE|\b)\Z},
            "number not broken up in threes: mark up numbers with stem:[]"
          )
        end
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
        style_regex(/(?:\A|\p{Zs})(?!e\.g\.|i\.e\.)
                    (?<num>[a-z]{1,2}\.(?:[a-z]{1,2}|\.))\b/ix,
                    "no dots in abbreviations", node, text)
        style_regex(/\b(?<num>ppm)\b/i,
                    "language-specific abbreviation", node, text)
      end

      # leaving out as problematic: N J K C S T H h d B o E
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|Hz|MHz|Pa|hPa|kJ|" \
                "V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|" \
                "bit|kB|MB|Hart|nat|Sh|var)".freeze

      # ISO/IEC DIR 2, 9.3
      def style_units(node, text)
        style_regex(/\b(?<num>[0-9][0-9,]*\p{Zs}+[\u00b0\u2032\u2033])/,
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
          style_regex(/\b(?<num>[0-9][0-9,]*\p{Zs}+#{k})\b/,
                      "non-standard unit (should be #{v})", node, text)
        end
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-and
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-andor
      def style_punct(node, text)
        @lang == "en" and style_regex(/\b(?<num>and\/?or)\b/i,
                                      "Use 'either x or y, or both'", node, text)
        style_regex(/\p{Zs}(?<num>&)\p{Zs}/i,
                    "Avoid ampersand in ordinary text'", node, text)
        eref_style_punct(node)
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-r-ref_unnumbered
      def eref_style_punct(node)
        node.xpath(".//eref[@type='footnote']").each do |e|
          /^\p{P}/.match?(e.next&.text) or next
          style_warning(node, "superscript cross-reference followed by punctuation",
                        node.to_xml)
        end
      end

      def style_warning(node, msg, text = nil)
        return if @novalid

        w = msg
        w += ": #{text}" if text
        @log.add("Style", node, w)
      end

      ASSETS_TO_STYLE =
        "//termsource | //formula | //termnote | " \
        "//p[not(ancestor::boilerplate)] | //li[not(p)] | //dt | " \
        "//dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze

      def asset_style(root)
        root.xpath("//example | //termexample").each { |e| example_style(e) }
        root.xpath("//definition/verbal-definition").each do |e|
          definition_style(e)
        end
        root.xpath("//note").each { |e| note_style(e) }
        root.xpath("//fn").each { |e| footnote_style(e) }
        root.xpath(ASSETS_TO_STYLE).each { |e| style(e, extract_text(e)) }
        norm_bibitem_style(root)
        super
      end
    end
  end
end
