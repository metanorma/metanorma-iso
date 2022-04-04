module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def add_id
        %(id="_#{UUIDTools::UUID.random_create}")
      end

      def index(xml)
        if xml.at(ns("//index"))
          i = xml.at(ns("//indexsect")) ||
            xml.root.add_child("<indexsect #{add_id}><title>#{@i18n.index}"\
                               "</title></indexsect>").first
          index = sort_indexterms(xml.xpath(ns("//index")),
                                  xml.xpath(ns("//index-xref[@also = 'false']")),
                                  xml.xpath(ns("//index-xref[@also = 'true']")))
          index1(xml, i, index)
        else xml.xpath(ns("//indexsect")).each(&:remove)
        end
      end

      def index1(docxml, indexsect, index)
        c = indexsect.add_child("<ul></ul>").first
        index.keys.sort.each do |k|
          words = index[k].keys.each_with_object({}) do |w, v|
            v[sortable(w).downcase] = w
          end
          words.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            c.add_child index_entries(words, index[k], w)
          end
        end
        index1_cleanup(docxml)
      end

      def index1_cleanup(docxml)
        docxml.xpath(ns("//indexsect//xref")).each do |x|
          x.children.remove
        end
        @xrefs.bookmark_anchor_names(docxml)
      end

      def sortable(str)
        HTMLEntities.new.decode(Nokogiri::XML.fragment(str).text)
      end

      def index_entries_opt
        { xref_lbl: ", ", see_lbl: ", #{see_lbl}", also_lbl: ", #{also_lbl}" }
      end

      def index_entries(words, index, primary)
        ret = index_entries_head(words[primary],
                                 index.dig(words[primary], nil, nil),
                                 index_entries_opt)
        words2 = index[words[primary]]&.keys&.reject do |k|
                   k.nil?
                 end&.each_with_object({}) { |w, v| v[w.downcase] = w }
        unless words2.empty?
          ret += "<ul>"
          words2.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            ret += index_entries2(words2, index[words[primary]], w)
          end
          ret += "</ul>"
        end
        "#{ret}</li>"
      end

      def index_entries2(words, index, secondary)
        ret = index_entries_head(words[secondary],
                                 index.dig(words[secondary], nil),
                                 index_entries_opt)
        words3 = index[words[secondary]]&.keys&.reject do |k|
                   k.nil?
                 end&.each_with_object({}) { |w, v| v[w.downcase] = w }
        unless words3.empty?
          ret += "<ul>"
          words3.keys.localize(@lang.to_sym).sort.to_a.each do |w|
            ret += (index_entries_head(words3[w],
                                       index[words[secondary]][words3[w]],
                                       index_entries_opt) + "</li>")
          end
          ret += "</ul>"
        end
        "#{ret}</li>"
      end

      def index_entries_head(head, entries, opt)
        ret = "<li>#{head}"
        xref = entries&.dig(:xref)&.join(", ")
        see = index_entries_see(entries, :see)
        also = index_entries_see(entries, :also)
        ret += "#{opt[:xref_lbl]} #{xref}" if xref
        ret += "#{opt[:see_lbl]} #{see}" if see
        ret += "#{opt[:also_lbl]} #{also}" if also
        ret
      end

      def index_entries_see(entries, label)
        see_sort = entries&.dig(label) or return ""

        see_sort.each_with_object({}) do |w, v|
          v[sortable(w).downcase] = w
        end.keys.localize(@lang.to_sym).sort.to_a.map do |k|
          see_sort[k]
        end.join(", ")
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

      def extract_indexsee(val, terms, label)
        terms.each_with_object(val) do |t, v|
          term, term2, term3 = extract_indexterms_init(t)
          term_hash_init(v, term, term2, term3, label)
          v[term][term2][term3][label] << t&.at(ns("./target"))&.children&.to_xml
          t.remove
        end
      end

      def xml_encode_attr(str)
        HTMLEntities.new.encode(str, :basic, :hexadecimal)
          .gsub(/&#x([^;]+);/) do |_x|
          "&#x#{$1.upcase};"
        end
      end

      # attributes are decoded into UTF-8,
      # elements in extract_indexsee are still in entities
      def extract_indexterms(terms)
        terms.each_with_object({}) do |t, v|
          term, term2, term3 = extract_indexterms_init(t)
          index2bookmark(t)
          term_hash_init(v, term, term2, term3, :xref)
          to = t["to"] ? "to='#{t['to']}' " : ""
          v[term][term2][term3][:xref] << "<xref target='#{t['id']}' "\
                                          "#{to}pagenumber='true'/>"
        end
      end

      def extract_indexterms_init(term)
        %w(primary secondary tertiary).each_with_object([]) do |x, m|
          m << term&.at(ns("./#{x}"))&.children&.to_xml
        end
      end

      def term_hash_init(hash, term, term2, term3, label)
        hash[term] ||= {}
        hash[term][term2] ||= {}
        hash[term][term2][term3] ||= {}
        hash[term][term2][term3][label] ||= []
      end

      def index2bookmark(node)
        node.name = "bookmark"
        node.children.each(&:remove)
        node["id"] = "_#{UUIDTools::UUID.random_create}"
      end
    end
  end
end
