module Metanorma
  module ISO
    class Converter < Standoc::Converter
      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-lists
      def listcount_validate(doc)
        return if @novalid

        ol_count_validate(doc)
        li_depth_validate(doc)
      end

      def ol_count_validate(doc)
        doc.xpath("//clause | //annex").each do |c|
          next if c.xpath(".//ol").empty?

          ols = c.xpath(".//ol") -
            c.xpath(".//ul//ol | .//ol//ol | .//clause//ol")
          ols.size > 1 and
            style_warning(c, "More than 1 ordered list in a numbered clause",
                          nil)
        end
      end

      def li_depth_validate(doc)
        doc.xpath("//li//li//li//li").each do |l|
          l.at(".//li") and
            style_warning(l, "List more than four levels deep", nil)
        end
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-lists
      def list_punctuation(doc)
        return if @novalid

        ((doc.xpath("//ol") - doc.xpath("//ul//ol | //ol//ol")) +
         (doc.xpath("//ul") - doc.xpath("//ul//ul | //ol//ul"))).each do |list|
          next if skip_list_punctuation(list)

          prec = list.at("./preceding::text()[normalize-space(.) != ''][1]")
          list_punctuation1(list, prec&.text)
        end
      end

      def skip_list_punctuation(list)
        return true if list.at("./ancestor::table")

        list.xpath(".//li").each do |entry|
          l = entry.dup
          l.xpath(".//ol | .//ul").each(&:remove)
          l.text.split.size > 2 and return false
        end
        true
      end

      def list_punctuation1(list, prectext)
        prectext ||= ""
        entries = list.xpath(".//li")
        case prectext.strip.chars.last
        when ":", "" then list_after_colon_punctuation(list, entries)
        when "." then entries.each { |li| list_full_sentence(li) }
        else style_warning(list, "All lists must be preceded by "\
                                 "colon or full stop", prectext)
        end
      end

      # if first list entry starts lowercase, treat as sentence broken up
      def list_after_colon_punctuation(list, entries)
        lower = starts_lowercase?(list.at(".//li").text)
        entries.each_with_index do |li, i|
          if lower
            list_semicolon_phrase(li, i == entries.size - 1)
          else
            list_full_sentence(li)
          end
        end
      end

      def list_semicolon_phrase(elem, last)
        text = elem.text.strip
        starts_lowercase?(text) or
          style_warning(elem, "List entry of broken up sentence must start "\
                              "with lowercase letter", text)
        list_semicolon_phrase_punct(elem, text, last)
      end

      def list_semicolon_phrase_punct(elem, text, last)
        punct = text.sub(/^.*?(\S)\s*$/, "\\1")
        if last
          punct == "." or
            style_warning(elem, "Final list entry of broken up "\
                                "sentence must end with full stop", text)
        else
          punct == ";" or
            style_warning(elem, "List entry of broken up sentence must "\
                                "end with semicolon", text)
        end
      end

      def list_full_sentence(elem)
        text = elem.text.strip
        starts_uppercase(text) or
          style_warning(elem, "List entry of separate sentences must start "\
                              "with uppercase letter", text)
        punct = text.sub(/^.*?(\S)\s*$/, "\\1")
        punct == "." or
          style_warning(elem, "List entry of separate sentences must "\
                              "end with full stop", text)
      end

      # allow that all-caps word (acronym) is agnostic as to lowercase
      def starts_lowercase?(text)
        text.match?(/^[^[[:upper:]][[:lower:]]]*[[:lower:]]/) ||
          text.match?(/^[^[[:upper:]][[:lower:]]]*[[:upper:]][[:upper:]]+[^[[:alpha:]]]/)
      end

      def starts_uppercase?(text)
        text.match?(/^[^[[:upper:]][[:lower:]]]*[[:upper:]]/)
      end
    end
  end
end
