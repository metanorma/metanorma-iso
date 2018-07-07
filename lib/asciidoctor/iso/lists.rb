require "pp"

module Asciidoctor
  module ISO
    module Lists
      def li(xml_ul, item)
        xml_ul.li do |xml_li|
          if item.blocks?
            xml_li.p(**id_attr(item)) { |t| t << item.text }
            xml_li << item.content
          else
            xml_li.p(**id_attr(item)) { |p| p << item.text }
          end
        end
      end

      def ulist(node)
        return reference(node) if in_norm_ref? || in_biblio?
        noko do |xml|
          xml.ul **id_attr(node) do |xml_ul|
            node.items.each do |item|
              li(xml_ul, item)
            end
          end
        end.join("\n")
      end

      def olist_style(style)
        return "alphabet" if style == "loweralpha"
        return "roman" if style == "lowerroman"
        return "roman_upper" if style == "upperroman"
        return "alphabet_upper" if style == "upperalpha"
        style
      end

      def olist(node)
        noko do |xml|
          xml.ol **attr_code(id: Utils::anchor_or_uuid(node),
                             type: olist_style(node.style)) do |xml_ol|
            node.items.each { |item| li(xml_ol, item) }
          end
        end.join("\n")
      end

      def dt(terms, xml_dl)
        terms.each_with_index do |dt, idx|
          xml_dl.dt { |xml_dt| xml_dt << dt.text }
          if idx < terms.size - 1
            xml_dl.dd
          end
        end
      end

      def dd(dd, xml_dl)
        if dd.nil?
          xml_dl.dd
          return
        end
        xml_dl.dd do |xml_dd|
          xml_dd.p { |t| t << dd.text } if dd.text?
          xml_dd << dd.content if dd.blocks?
        end
      end

      def dlist(node)
        noko do |xml|
          xml.dl **id_attr(node) do |xml_dl|
            node.items.each do |terms, dd|
              dt(terms, xml_dl)
              dd(dd, xml_dl)
            end
          end
        end.join("\n")
      end

      def colist(node)
        noko do |xml|
          node.items.each_with_index do |item, i|
            xml.annotation **attr_code(id: i + 1) do |xml_li|
              xml_li.p { |p| p << item.text }
            end
          end
        end.join("\n")
      end
    end
  end
end
