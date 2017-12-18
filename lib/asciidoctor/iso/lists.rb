module Asciidoctor
  module ISO
    module Lists
      def ulist(node)
        result = []
        result << noko do |xml|
          ul_attributes = {
            anchor: node.id,
          }

          xml.ul **attr_code(ul_attributes) do |xml_ul|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }

              xml_ul.li **attr_code(li_attributes) do |xml_li|
                if item.blocks?
                  xml_li.t do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li << item.text
                end
              end
            end
          end
        end
        result
      end

      def olist(node)
        result = []

        result << noko do |xml|
          ol_attributes = {
            anchor: node.id,
            type: node.style,
          }

          xml.ol **attr_code(ol_attributes) do |xml_ol|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }
              xml_ol.li **attr_code(li_attributes) do |xml_li|
                if item.blocks?
                  xml_li.t do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li << item.text
                end
              end
            end
          end
        end
        result
      end

      def dlist(node)
        result = []
        result << noko do |xml|
          dl_attributes = {
            anchor: node.id,
          }

          xml.dl **attr_code(dl_attributes) do |xml_dl|
            node.items.each do |terms, dd|
              terms.each_with_index do |dt, idx|
                xml_dl.dt { |xml_dt| xml_dt << dt.text }
                if idx < terms.size - 1
                  xml_dl.dd
                end
              end

              if dd.nil?
                xml_dl.dd
              else
                xml_dl.dd do |xml_dd|
                  if dd.blocks?
                    if dd.text?
                      xml_dd.t { |t| t << dd.text }
                    end
                    xml_dd << dd.content
                  else
                    xml_dd << dd.text
                  end
                end
              end
            end
          end
        end
        result
      end
    end
  end
end

