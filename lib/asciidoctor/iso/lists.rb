require "pp"
module Asciidoctor
  module ISO
    module Lists
      def ulist(node)
        return norm_ref(node) if $norm_ref
        return biblio_ref(node) if $biblio
        noko do |xml|
          xml.ul **attr_code(anchor: node.id) do |xml_ul|
            node.items.each do |item|
              xml_ul.li **attr_code(anchor: item.id) do |xml_li|
                Validate::style(item, item.text)
                if item.blocks?
                  xml_li.p { |t| t << item.text }
                  xml_li << item.content
                else
                  xml_li.p { |p| p << item.text }
                end
              end
            end
          end
        end.join("\n")
      end

      def isorefmatches(xml, matched)
        ref_attributes = {
          anchor: matched[:anchor],
        }
        xml.iso_ref_title **attr_code(ref_attributes) do |t|
          t.isocode matched[:code]
          t.isodate matched[:year] if matched[:year]
          t.isotitle { |i| i << ref_normalise(matched[:text]) }
        end
      end

      def isorefmatches2(xml, matched2)
        ref_attributes = {
          anchor: matched2[:anchor],
        }
        xml.iso_ref_title **attr_code(ref_attributes) do |t|
          t.isocode matched2[:code]
          t.isodate "--"
          t.date_footnote matched2[:fn]
          t.isotitle { |i| i << ref_normalise(matched2[:text]) }
        end
      end

      def ref_normalise(ref)
        ref.gsub(/&#8201;&#8212;&#8201;/, " -- ").
          gsub(/&amp;amp;/, "&amp;")
      end

      def norm_ref(node)
        noko do |xml|
          node.items.each do |item|
            matched = %r{^<ref\sanchor="(?<anchor>[^"]+)">
            \[ISO\s(?<code>[0-9-]+)(:(?<year>[0-9]+))?\]</ref>,?\s
            (?<text>.*)$}x.match item.text
            matched2 = %r{^<ref\sanchor="(?<anchor>[^"]+)">
            \[ISO\s(?<code>[0-9-]+):--\]</ref>,?\s?
            <fn>(?<fn>[^\]]+)</fn>,?\s?(?<text>.*)$}x.match item.text
            if matched2.nil?
              if matched.nil?
                warning(node, "normative reference not in expected format", item.text)
              else
                isorefmatches(xml, matched)
              end
            else
              isorefmatches2(xml, matched2)
            end
          end
        end.join("\n")
      end

      def biblio_ref(node)
        noko do |xml|
          node.items.each do |item|
            matched = %r{^<ref\sanchor="(?<anchor>[^"]+)">
            \[ISO\s(?<code>[0-9-]+)(:(?<year>[0-9]+))?\]</ref>,?\s
            (?<text>.*)$}.match item.text
            matched2 = %r{^<ref\sanchor="(?<anchor>[^"]+)">
            \[ISO\s(?<code>[0-9-]+):--\]</ref>,?\s?
            <fn>(?<fn>[^\]]+)</fn>,?\s?(?<text>.*)$}.match item.text
            if matched2.nil?
              if matched.nil?
                xml.reference do |t|
                  t.p { |p| p << ref_normalise(item.text) }
                end
              else
                isorefmatches(xml, matched)
              end
            else
              isorefmatches2(xml, matched2)
            end
          end
        end.join("\n")
      end

      def olist(node)
        noko do |xml|
          xml.ol **attr_code(anchor: node.id, type: node.style) do |xml_ol|
            node.items.each do |item|
              xml_ol.li **attr_code(anchor: item.id) do |xml_li|
                Validate::style(item, item.text)
                if item.blocks?
                  xml_li.p { |t| t << item.text }
                  xml_li << item.content
                else
                  xml_li.p { |p| p << item.text }
                end
              end
            end
          end
        end.join("\n")
      end

      def dlist(node)
        noko do |xml|
          xml.dl **attr_code(anchor: node.id) do |xml_dl|
            node.items.each do |terms, dd|
              terms.each_with_index do |dt, idx|
                Validate::style(dt, dt.text)
                xml_dl.dt { |xml_dt| xml_dt << dt.text }
                if idx < terms.size - 1
                  xml_dl.dd
                end
              end

              if dd.nil?
                xml_dl.dd
              else
                xml_dl.dd do |xml_dd|
                  Validate::style(dd, dd.text)
                  if dd.blocks?
                    if dd.text?
                      xml_dd.p { |t| t << dd.text }
                    end
                    xml_dd << dd.content
                  else
                    Validate::style(dd, dd.text)
                    xml_dd.p { |t| t << dd.text }
                  end
                end
              end
            end
          end
        end.join("\n")
      end

      def colist(node)
        noko do |xml|
          xml.colist **attr_code(anchor: node.id) do |xml_ul|
            node.items.each_with_index do |item, i|
              xml_ul.annotation **attr_code(id: i + 1) do |xml_li|
                Validate::style(item, item.text)
                xml_li << item.text
              end
            end
          end
        end.join("\n")
      end
    end
  end
end
