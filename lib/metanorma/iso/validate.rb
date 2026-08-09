require "metanorma-standoc"
require "nokogiri"
require "tokenizer"
require "htmlentities"

module Metanorma
  module Iso
    module LegacyChecks
      REQUIREMENT_RE_STR = <<~REGEXP.freeze
        \\b
         ( shall | (is|are)_to |
           (is|are)_required_(not_)?to |
           (is|are)_required_that |
           has_to |
           only\\b[^.,]+\\b(is|are)_permitted |
           it_is_necessary |
           (is|are)_not_(allowed | permitted |
                         acceptable | permissible) |
           (is|are)_not_to_be |
           [.,:;]_do_not )
        \\b
      REGEXP

      RECOMMENDATION_RE_STR = <<~REGEXP.freeze
        \\b
            should |
            ought_(not_)?to |
            it_is_(not_)?recommended_that
        \\b
      REGEXP

      PERMISSION_RE_STR = <<~REGEXP.freeze
        \\b
             may |
            (is|are)_(permitted | allowed | permissible ) |
            it_is_not_required_that |
            no\\b[^.,]+\\b(is|are)_required
        \\b
      REGEXP

      def str_to_regexp(str)
        Regexp.new(str.gsub(/\s/, "").gsub("_", "\\s"), Regexp::IGNORECASE)
      end

      def requirement_check(text)
        @lang == "en" or return
        re = str_to_regexp(REQUIREMENT_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each { |t| return t if re.match t }
        nil
      end

      def style_no_guidance(node, text, docpart)
        @lang == "en" or return
        r = requirement_check(text) and style_warning(node, "#{docpart} may contain requirement", r, display: false)
        re_perm = str_to_regexp(PERMISSION_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each { |t| (re_perm.match(t)) and (style_warning(node, "#{docpart} may contain permission", t, display: false); break) }
        re_rec = str_to_regexp(RECOMMENDATION_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each { |t| (re_rec.match(t)) and (style_warning(node, "#{docpart} may contain recommendation", t, display: false); break) }
      end

      def extract_text(node)
        node.nil? and return ""
        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath(".//link | .//locality | .//localityStack | .//stem | .//sourcecode").each(&:remove)
        ret = +""
        node1.traverse { |x| ret << x.text if x.text? }
        HTMLEntities.new.decode(ret)
      end

      def style_warning(node, msg, text = nil, display: true)
        @novalid and return
        w = msg; w += ": #{text}" if text
        @log.add("STANDOC_48", node, params: [w], display:)
      end

      def style_regex(regex, warning, node, text)
        (m = regex.match(text)) && style_warning(node, warning, m[:num])
      end

      def style_two_regex_not_prev(n, text, regex, re_prev, warning)
        return if text.nil?
        arr = Tokenizer::WhitespaceTokenizer.new.tokenize(text)
        arr.each_index do |i|
          m = regex.match arr[i]
          m_prev = i.zero? ? nil : re_prev.match(arr[i - 1])
          style_warning(n, warning, m[:num]) if !m.nil? && m_prev.nil?
        end
      end

      ASSETS_TO_STYLE = "//term//source | //formula | //termnote | //p[not(ancestor::boilerplate)] | //li[not(p)] | //dt | //dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze
      SI_UNIT = "(m|cm|mm|km|μm|nm|g|kg|mgmol|cd|rad|sr|Hz|MHz|Pa|hPa|kJ|V|kV|W|MW|kW|F|μF|Ω|Wb|°C|lm|lx|Bq|Gy|Sv|kat|l|t|eV|u|Np|Bd|bit|kB|MB|Hart|nat|Sh|var)".freeze
      NONSTD_UNITS = { sec: "s", mins: "min", hrs: "h", hr: "h", cc: "cm^3", lit: "l", amp: "A", amps: "A", rpm: "r/min" }.freeze

      def style(node, text)
        @novalid and return
        @novalid_number or style_number(node, text)
        style_percent(node, text); style_abbrev(node, text); style_units(node, text)
        style_punct(node, text); style_subscript(node); style_problem_words(node, text)
      end

      def style_problem_words(node, text)
        style_regex(/\b(?<num>billions?)\b/i, "ambiguous number", node, text)
      end

      def foreword_style(_node); end
      def scope_style(node); @novalid and return; style_no_guidance(node, extract_text(node), "Scope"); end
      def introduction_style(node); @novalid and return; (r = requirement_check(extract_text(node))) and style_warning(node, "Introduction may contain requirement", r, display: false); end
      def definition_style(node); @novalid and return; (r = requirement_check(extract_text(node))) and style_warning(node, "Definition may contain requirement", r, display: false); end
      def example_style(node); @novalid and return; style_no_guidance(node, extract_text(node), "Example"); style(node, extract_text(node)); end
      def note_style(node); @novalid and return; style_no_guidance(node, extract_text(node), "Note"); style(node, extract_text(node)); end
      def footnote_style(node); @novalid and return; style_no_guidance(node, extract_text(node), "Footnote"); style(node, extract_text(node)); end

      def style_abbrev(node, text)
        style_regex(/(?:\A|\p{Zs})(?!e\.g\.|i\.e\.) (?<num>[a-z]{1,2}\.(?:[a-z]{1,2}|\.))\b/ix, "no dots in abbreviations", node, text)
        style_regex(/\d\s*(?<num>ppm)\b/i, "language-specific abbreviation of unit (ppm)", node, text)
      end

      def style_punct(node, text)
        @lang == "en" and style_regex(/\b(?<num>and\/?or)\b/i, "Use 'either x or y, or both'", node, text)
        style_regex(/\p{Zs}(?<num>&)\p{Zs}/i, "Avoid ampersand in ordinary text'", node, text)
        node.xpath(".//eref[@type='footnote']").each { |e| /^\p{P}/.match?(e.next&.text) and style_warning(node, "superscript cross-reference followed by punctuation", node.to_xml) }
      end

      def asset_style(root)
        root.xpath("//example | //termexample").each { |e| example_style(e) }
        root.xpath("//definition/verbal-definition").each { |e| definition_style(e) }
        root.xpath("//note").each { |e| note_style(e) }
        root.xpath("//fn").each { |e| footnote_style(e) }
        root.xpath(ASSETS_TO_STYLE).each { |e| style(e, extract_text(e)) }
      end

      def style_subscript(node)
        node.xpath(".//sub[not(ancestor::sub)]").each do |x|
          depth = calculate_subscript_depth(x)
          next if depth < 2
          style_warning(node, depth >= 3 ? "no more than 3 levels of subscript nesting allowed" : "may contain nested subscripts", x.to_xml)
        end
      end

      def style_number(node, text)
        style_number_grouping(node, text)
        style_regex(/(?:^|\p{Zs})(?<num>[0-9]+\.[0-9]+)(?!\.[0-9])/i, "possible decimal point: mark up numbers with stem:[]", node, text)
        @lang == "en" and style_regex(/\b(?<num>billions?)\b/i, "ambiguous number", node, text)
        style_regex(/(?:^|\p{Zs})(?<num>-[0-9][0-9,.]*)/i, "hyphen instead of minus sign U+2212", node, text)
        @novalid_number = true
      end

      def style_number_grouping(node, text)
        regex = @validate_year ? /^(?<num>-?[0-9]{4,}[,0-9]*)\Z/ : /^(?<num>-?(?:[0-9]{5,}[,0-9]*|[03-9]\d\d\d|1[0-8]\d\d|2[1-9]\d\d|20[5-9]\d))\Z/
        prev = @validate_year ? %r{\b(ISO|IEC|IEEE|(in|January|February|March|April|May|June|August|September|October|November|December)\b)\Z} : %r{\b(ISO|IEC|IEEE|\b)\Z}
        style_two_regex_not_prev(node, text, regex, prev, "number not broken up in threes: mark up numbers with stem:[]")
      end

      def style_percent(node, text)
        style_regex(/\b(?<num>[0-9.,]+%)/, "no space before percent sign", node, text)
      end

      def style_units(node, text)
        style_regex(/\b(?<num>[0-9][0-9,]*\p{Zs}+[°′″])/, "space between number and degrees/minutes/seconds", node, text)
        style_regex(/(?<![A-Za-z0-9])(?<num>[1-9][0-9,]*#{SI_UNIT})\b/o, "no space between number and SI unit", node, text)
        NONSTD_UNITS.each { |k, v| style_regex(/\b(?<num>[0-9][0-9,]*\p{Zs}+#{k})\b/, "non-standard unit (should be #{v})", node, text) }
      end

      def calculate_subscript_depth(sub)
        return 1 if sub.xpath(".//sub").empty?
        sub.xpath(".//sub").map { |n| 1 + calculate_subscript_depth(n) }.max
      end

      def list_punctuation(doc)
        return if @novalid
        ((doc.xpath("//ol") - doc.xpath("//ul//ol | //ol//ol")) + (doc.xpath("//ul") - doc.xpath("//ul//ul | //ol//ul"))).each do |list|
          next if skip_list_punctuation(list)
          prec = list.at("./preceding::text()[normalize-space(.) != ''][1]")
          list_punctuation1(list, prec&.text)
        end
      end

      def skip_list_punctuation(list)
        return true if list.at("./ancestor::table")
        return true if list.at("./following-sibling::term")
        list.xpath(".//li").each do |entry|
          l = entry.dup; l.xpath(".//ol | .//ul").each(&:remove)
          return false if l.text.split.size > 2
        end
        true
      end

      def list_punctuation1(list, prectext)
        prectext ||= ""; entries = list.xpath(".//li")
        return unless %w[Cyrl Latn Grek].include?(@script)
        case prectext.strip[-1]
        when ":", "" then list_after_colon_punctuation(list, entries)
        when "." then entries.each { |li| list_full_sentence(li) }
        else style_warning(list, "All lists must be preceded by colon or full stop", prectext, display: false)
        end
      end

      def list_after_colon_punctuation(list, entries)
        lower = starts_lowercase?(list.at(".//li").text)
        entries.each_with_index { |li, i| lower ? list_semicolon_phrase(li, i == entries.size - 1) : list_full_sentence(li) }
      end

      def list_semicolon_phrase(elem, last)
        text = elem.text.strip
        starts_lowercase?(text) or style_warning(elem, "List entry of broken up sentence must start with lowercase letter", text, display: false)
        punct = text.strip.sub(/^.*?(\S)\z/m, "\\1")
        if last; punct == "." or style_warning(elem, "Final list entry must end with full stop", text, display: false)
        else; punct == ";" or style_warning(elem, "List entry must end with semicolon", text, display: false); end
      end

      def list_full_sentence(elem)
        return unless %w[Cyrl Latn Grek].include?(@script)
        text = elem.text.strip
        starts_uppercase?(text) || starts_numeric?(elem) or style_warning(elem, "List entry must start with uppercase letter", text, display: false)
        text.strip.sub(/^.*?(\S)\z/m, "\\1") == "." or style_warning(elem, "List entry must end with full stop", text, display: false)
      end

      def starts_lowercase?(text)
        text.match?(/^[^[[:upper:]][[:lower:]]]*[[:lower:]]/) ||
          text.match?(/^[^[[:upper:]][[:lower:]]]*[[:upper:]][[:upper:]]+[^[[:alpha:]]]/)
      end

      def starts_uppercase?(text)
        text.match?(/^[^[[:upper:]][[:lower:]]]*[[:upper:]]/)
      end

      def starts_numeric?(elem)
        queue = [elem]
        until queue.empty?
          n = queue.shift
          return true if n.name == "stem"
          return true if %w[xref eref].include?(n.name) && n.text.strip.empty?
          if n.text?; t = n.text.strip; return true if !t.empty? && /^\d/.match?(t); end
          queue.concat(n.children.to_a)
        end
        false
      end

      def title_no_full_stop_validate(root)
        root.xpath("//preface//title | //sections//title | //annex//title | //references/title | //preface//name | //sections//name | //annex//name").each do |t|
          style_regex(/\A(?<num>.+\.\Z)/i, "No full stop at end of title or caption", t, t.text.strip)
        end
      end

      def title_validate(root); title_no_full_stop_validate(root); end

      def normref_validate(root)
        f = root.at("//references[@normative = 'true']") || return
        f.at("./references | ./clause") && @log.add("ISO_24", f)
      end

      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[@type = 'scope']"))
        @doctype == "technical-report" and
          root.xpath("//sections/clause[not(@type = 'scope')] | //annex").each do |s|
            (r = requirement_check(extract_text(s))) and style_warning(s, "Technical Report clause may contain requirement", r)
          end
      end

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause")
          .each { |c| style_warning(c, "Exceeds the maximum clause depth of 7", nil) }
      end
    end

    class Validate < Standoc::Validate
      include LegacyChecks

      def copied_instance_variables
        super + %i[amd vocab validate_years]
      end

      def validate(doc)
        @log.add_error_ranges(doc)
        content_validate(doc)
      end

      def content_validate(doc)
        @doctype = doc.at("//bibdata/ext/doctype")&.text
        repeat_id_validate(doc.root)
        xref_validate(doc)
        root = doc.root
        title_validate(root)
        section_style(root)
        subclause_validate(root)
        list_punctuation(doc)
        asset_style(root)
        model_validate(doc)
        fatalerrors = @log.abort_messages
        fatalerrors.empty? or
          @conv.clean_abort("\n\nFATAL ERRORS:\n\n#{fatalerrors.join("\n\n")}", doc)
      end

      def model_validate(doc)
        state = Metanorma::Iso::Validation::ConverterState.new(
          lang: @lang, script: @script, doctype: @doctype,
          vocab: @vocab, amd: @amd, i18n: @i18n,
          novalid: @novalid, document: @localdir
        )
        Metanorma::Iso::Validation::ModelValidator.run(
          doc.to_xml, log: @log, state: state
        )
      end

      def repeat_id_validate1(elem)
        return unless elem["id"]
        @doc_ids[elem["id"]] ||= { line: elem.line, anchor: elem["anchor"] }.compact
      end

      def repeat_anchor_validate1(elem)
        return unless elem["anchor"]
        @doc_anchors[elem["anchor"]] ||= { line: elem.line, id: elem["id"] }
        @doc_anchor_seq << elem["anchor"]
      end
    end
  end
end
