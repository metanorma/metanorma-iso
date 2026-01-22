module Metanorma
  module Iso
    class Converter < Standoc::Converter
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-quantity
      def style_subscript(node)
        style_subscript_proper(node)
        style_subscript_mathml(node)
      end

      # Check HTML subscripts - only topmost level subs (no sub ancestors)
      def style_subscript_proper(node)
        node.xpath(".//sub[not(ancestor::sub)]").each do |x|
          depth = calculate_subscript_depth(x)
          depth < 2 and next # No warning for single level subscripts
          if [2, 3].include?(depth)
            style_warning(node, "may contain nested subscripts", x.to_xml)
          else # depth >= 3
            style_warning(node, "no more than 3 levels of subscript nesting allowed",
                          x.to_xml)
          end
        end
      end

      # Check MathML subscripts - only topmost level msubs (no msub ancestors)
      def style_subscript_mathml(node)
        node.xpath(".//m:msub[not(ancestor::m:msub)]",
                   "m" => MATHML_NS).each do |x|
          depth = calculate_mathml_subscript_depth(x)
          depth < 2 and next # No warning for single level subscripts
          if [2, 3].include?(depth)
            style_warning(node, "may contain nested subscripts", x.to_xml)
          else # depth > 3
            style_warning(node, "no more than 3 levels of subscript nesting allowed",
                          x.to_xml)
          end
        end
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

      # leaving out as problematic: N J K C S T H h d B o E
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|Hz|MHz|Pa|hPa|kJ|" \
                "V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|" \
                "bit|kB|MB|Hart|nat|Sh|var)".freeze

      # ISO/IEC DIR 2, 9.3
      def style_units(node, text)
        style_regex(/\b(?<num>[0-9][0-9,]*\p{Zs}+[\u00b0\u2032\u2033])/,
                    "space between number and degrees/minutes/seconds",
                    node, text)
        style_regex(/(?<![A-Za-z0-9])(?<num>[1-9][0-9,]*#{SI_UNIT})\b/o,
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

      private

      def calculate_subscript_depth(sub_element)
        sub_element.xpath(".//sub").empty? and return 1
        max_depth = 1
        sub_element.xpath(".//sub").each do |nested_sub|
          depth = 1 + calculate_subscript_depth(nested_sub)
          max_depth = [max_depth, depth].max
        end
        max_depth
      end

      def calculate_mathml_subscript_depth(msub_element)
        msub_element.xpath(".//m:msub", "m" => MATHML_NS).empty? and return 1
        max_depth = 1
        msub_element.xpath(".//m:msub", "m" => MATHML_NS).each do |nested_msub|
          depth = 1 + calculate_mathml_subscript_depth(nested_msub)
          max_depth = [max_depth, depth].max
        end
        max_depth
      end
    end
  end
end
