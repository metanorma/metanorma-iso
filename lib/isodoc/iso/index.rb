module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def add_id
        %(id="_#{UUIDTools::UUID.random_create}")
      end

      def index(docxml)
        unless docxml.at(ns("//index"))
          docxml.xpath(ns("//indexsect")).each { |i| i.remove }
          return
        end
        i = docxml.at(ns("//indexsect")) ||
          docxml.root.add_child("<indexsect #{add_id}><title>#{@i18n.index}</title></indexsect>").first
        index = sort_indexterms(docxml.xpath(ns("//index")), docxml.xpath(ns("//index-xref[@also = 'false']")),
                                docxml.xpath(ns("//index-xref[@also = 'true']")))
        index1(docxml, i, index)
      end

      def index1(docxml, i, index)
        c = i.add_child("<ul></ul>").first
        index.keys.sort.each do |k|
          #c = i.add_child "<clause #{add_id}><title>#{k}</title><ul></ul></clause>"
          words = index[k].keys.each_with_object({}) { |w, v| v[sortable(w).downcase] = w }
          words.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            #c.first.at(ns("./ul")).add_child index_entries(words, index[k], w)
            c.add_child index_entries(words, index[k], w)
          end
        end
        docxml.xpath(ns("//indexsect//xref")).each { |x| x.children.remove }
        @xrefs.bookmark_anchor_names(docxml)
      end

      def sortable(s)
        HTMLEntities.new.decode(Nokogiri::XML.fragment(s).text)
      end

      def index_entries_opt
        { xref_lbl: ", ", see_lbl: ", #{see_lbl}", also_lbl: ", #{also_lbl}" }
      end

      def index_entries(words, index, primary)
        ret = index_entries_head(words[primary], index.dig(words[primary], nil, nil), index_entries_opt)
        words2 = index[words[primary]]&.keys&.reject { |k| k.nil?}&.each_with_object({}) { |w, v| v[w.downcase] = w }
        unless words2.empty?
          ret += "<ul>"
          words2.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            ret += index_entries2(words2, index[words[primary]], w)
          end
          ret += "</ul>"
        end
        ret + "</li>"
      end

      def index_entries2(words, index, secondary)
        ret = index_entries_head(words[secondary], index.dig(words[secondary], nil), index_entries_opt)
        words3 = index[words[secondary]]&.keys&.reject { |k| k.nil?}&.each_with_object({}) { |w, v| v[w.downcase] = w }
        unless words3.empty?
          ret += "<ul>"
          words3.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            ret += (index_entries_head(words3[w], index[words[secondary]][words3[w]], index_entries_opt) + "</li>")
          end
          ret += "</ul>"
        end
        ret + "</li>"
      end

      def index_entries_head(head, entries, opt)
        ret = "<li>#{head}"
        xref = entries&.dig(:xref)&.join(", ")
        see_sort = entries&.dig(:see)&.each_with_object({}) { |w, v| v[sortable(w).downcase] = w }
        see = see_sort&.keys&.localize(@lang.to_sym)&.sort&.to_a&.map { |k| see_sort[k] }&.join(", ")
        also_sort = entries&.dig(:also)&.each_with_object({}) { |w, v| v[sortable(w).downcase] = w }
        also = also_sort&.keys&.localize(@lang.to_sym)&.sort&.to_a&.map { |k| also_sort[k] }&.join(", ")
        ret += "#{opt[:xref_lbl]} #{xref}" if xref
        ret += "#{opt[:see_lbl]} #{see}" if see
        ret += "#{opt[:also_lbl]} #{also}" if also
        ret
      end

      def see_lbl
        @lang == "en" ? @i18n.see : "<em>#{@i18n.see}</em>"
      end

      def also_lbl
        @lang == "en" ? @i18n.see_also : "<em>#{@i18n.see_also}</em>"
      end

      def sort_indexterms(terms, see, also)
        index = extract_indexterms(terms)
        index = extract_indexsee(index, see, :see)
        index = extract_indexsee(index, also, :also)
        index.keys.sort.each_with_object({}) do |k, v|
          v[sortable(k)[0].upcase.transliterate] ||= {}
          v[sortable(k)[0].upcase.transliterate][k] = index[k]
        end
      end

      def extract_indexsee(v, terms, label)
        terms.each_with_object(v) do |t, v|
          term = t&.at(ns("./primary"))&.children&.to_xml
          term2 = t&.at(ns("./secondary"))&.children&.to_xml
          term3 = t&.at(ns("./tertiary"))&.children&.to_xml
          v[term] ||= {}
          v[term][term2] ||= {}
          v[term][term2][term3] ||= {}
          v[term][term2][term3][label] ||= []
          v[term][term2][term3][label] << t&.at(ns("./target"))&.children&.to_xml
          t.remove
        end
      end

      def xml_encode_attr(s)
        HTMLEntities.new.encode(s, :basic, :hexadecimal).gsub(/\&#x([^;]+);/) { |x| "&#x#{$1.upcase};" }
      end

      # attributes are decoded into UTF-8, elements in extract_indexsee are still in entities
      def extract_indexterms(terms)
        terms.each_with_object({}) do |t, v|
          term = t&.at(ns("./primary"))&.children&.to_xml
          term2 = t&.at(ns("./secondary"))&.children&.to_xml
          term3 = t&.at(ns("./tertiary"))&.children&.to_xml
          index2bookmark(t)
          v[term] ||= {}
          v[term][term2] ||= {}
          v[term][term2][term3] ||= {}
          v[term][term2][term3][:xref] ||= []
          to = t["to"] ? "to='#{t['to']}' " : ""
          v[term][term2][term3][:xref] << "<xref target='#{t['id']}' #{to}pagenumber='true'/>"
        end
      end

      def index2bookmark(t)
        t.name = "bookmark"
        t.children.each { |x| x.remove }
        t["id"] = "_#{UUIDTools::UUID.random_create}"
      end
    end
  end
end
