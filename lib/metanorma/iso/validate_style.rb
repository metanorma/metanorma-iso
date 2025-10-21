require "metanorma-standoc"
require "nokogiri"
require "tokenizer"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def extract_text(node)
        node.nil? and return ""
        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath(".//link | .//locality | .//localityStack | " \
          ".//stem | .//sourcecode").each(&:remove)
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
        r = requirement_check(extract_text(node)) and
          style_warning(node, "Introduction may contain requirement", r,
                        display: false)
      end

      # ISO/IEC DIR 2, 16.5.6
      def definition_style(node)
        @novalid and return
        r = requirement_check(extract_text(node)) and
          style_warning(node, "Definition may contain requirement", r,
                        display: false)
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
        text.nil? and return
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
        style_problem_words(node, text)
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-need
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-might
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-family
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-s-it
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-use-of
      def style_problem_words(node, text)
        r = ambig_words_check(text) and
          style_warning(node, "may contain ambiguous provision", r,
                        display: false)
        r = misspelled_words_check(text) and
          style_warning(node, "dispreferred spelling", r,
                        display: false)
        style_regex(/\b(?<num>billions?)\b/i, "ambiguous number", node, text)
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

      def style_warning(node, msg, text = nil, display: true)
        @novalid and return
        w = msg
        w += ": #{text}" if text
        @log.add("STANDOC_48", node, params: [w], display:)
      end

      ASSETS_TO_STYLE =
        "//term//source | //formula | //termnote | " \
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
