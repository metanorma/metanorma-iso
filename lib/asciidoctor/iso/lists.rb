require "pp"
module Asciidoctor
  module ISO
    module Lists
      def ulist(node)
        return norm_ref(node) if $norm_ref
        return biblio_ref(node) if $biblio
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
                  xml_li.p do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li.p { |p| p << item.text }
                end
              end
            end
          end
        end
        result
      end

      def norm_ref(node)
        result = []
        result << noko do |xml|
          node.items.each do |item|
            #   element iso_ref_title { isocode, isodate?, isotitle }
            matched = /^ISO (?<code>[0-9-]+)(:(?<year>[0-9]+))?, (?<text>.*)$/.match item.text
            matched2 = /^ISO (?<code>[0-9-]+): \[(?<fn>[^\]]+)\], (?<text>.*)$/.match item.text
            if matched2.nil?
              if matched.nil?
                warn %(asciidoctor: WARNING (#{current_location(node)}): normative reference not in expected format: #{item.text})
              else
                xml.iso_ref_title do |t|
                  t.isocode matched[:code]
                  t.isodate matched[:year] if matched[:year]
                  t.isotitle { |i| i << matched[:text].gsub(/&#8201;&#8212;&#8201;/, " -- ") }
                end
              end
            else
              xml.iso_ref_title do |t|
                t.isocode matched2[:code]
                t.isodate do |d| 
                  d.date_footnote matched2[:fn]
                end
                t.isotitle { |i| i << matched2[:text].gsub(/&#8201;&#8212;&#8201;/, " -- ") }
              end
            end
          end
        end
        result
      end

      def biblio_ref(node)
        result = []
        result << noko do |xml|
          node.items.each do |item|
            xml.reference do |t|
              t.p { |p| p << item.text }
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
                  xml_li.p do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li.p { |p| p << item.text }
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
                      xml_dd.p { |t| t << dd.text }
                    end
                    xml_dd << dd.content
                  else
                    xml_dd.p { |t| t << dd.text }
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

