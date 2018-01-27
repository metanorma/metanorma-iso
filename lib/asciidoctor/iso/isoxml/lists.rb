require "pp"
module Asciidoctor
  module ISO
    module ISOXML
      module Lists
        def li(xml_ul, item)
          xml_ul.li do |xml_li|
            Validate::style(item, item.text)
            if item.blocks?
              xml_li.p **id_attr(item) do |t|
                t << item.text 
              end
              xml_li << item.content
            else
              xml_li.p **id_attr(item) do |p|
                p << item.text 
              end
            end
          end
        end

        def ulist(node)
          return reference(node, true) if $norm_ref
          return reference(node, false) if $biblio
          noko do |xml|
            xml.ul **id_attr(node) do |xml_ul|
              node.items.each do |item|
                li(xml_ul, item)
              end
            end
          end.join("\n")
        end

        def isorefmatches(xml, matched)
          ref_attributes = {
            id: matched[:anchor],
          }
          xml.iso_ref_title **attr_code(ref_attributes) do |t|
            t.isocode matched[:code]
            t.isodate matched[:year] if matched[:year]
            t.isotitle { |i| i << ref_normalise(matched[:text]) }
          end
        end

        def isorefmatches2(xml, matched2)
          ref_attributes = {
            id: matched2[:anchor],
          }
          xml.iso_ref_title **attr_code(ref_attributes) do |t|
            t.isocode matched2[:code]
            t.isodate "--"
            t.date_footnote matched2[:fn]
            t.isotitle { |i| i << ref_normalise(matched2[:text]) }
          end
        end

        def isorefmatches3(xml, matched2)
          ref_attributes = {
            id: matched2[:anchor],
          }
          xml.iso_ref_title **attr_code(ref_attributes) do |t|
            t.isocode matched2[:code], **attr_code(allparts: true)
            t.isotitle { |i| i << ref_normalise(matched2[:text]) }
          end
        end

        def ref_normalise(ref)
          ref.
            # gsub(/&#8201;&#8212;&#8201;/, " -- ").
            gsub(/&amp;amp;/, "&amp;")
        end

        @@iso_ref = %r{^<ref\sid="(?<anchor>[^"]+)">
        \[ISO\s(?<code>[0-9-]+)(:(?<year>[0-9]+))?\]</ref>,?\s
        (?<text>.*)$}xm

        @@iso_ref_no_year = %r{^<ref\sid="(?<anchor>[^"]+)">
        \[ISO\s(?<code>[0-9-]+):--\]</ref>,?\s?
        <fn[^>]*>(?<fn>[^\]]+)</fn>,?\s?(?<text>.*)$}xm

        @@iso_ref_all_parts = %r{^<ref\sid="(?<anchor>[^"]+)">
        \[ISO\s(?<code>[0-9]+)\s\(all\sparts\)\]</ref>(<p>)?,?\s?
        (?<text>.*)(</p>)?$}xm

        def reference1(node, item, xml, normative)
          matched = @@iso_ref.match item
          matched2 = @@iso_ref_no_year.match item
          matched3 = @@iso_ref_all_parts.match item
          if matched3.nil? && matched2.nil? && matched.nil?
            xml.reference do |r|
              r.p **id_attr do |p| 
                p << ref_normalise(item) 
              end
            end
          elsif !matched.nil? then isorefmatches(xml, matched)
          elsif !matched2.nil? then isorefmatches2(xml, matched2)
          elsif !matched3.nil? then isorefmatches3(xml, matched3)
          end
          if matched3.nil? && matched2.nil? && matched.nil? && normative
            Utils::warning(node, 
                           "non-ISO/IEC reference not expected as normative",
                           item)
          end
        end

        def reference(node, normative)
          noko do |xml|
            node.items.each do |item|
              reference1(node, item.text, xml, normative)
            end
          end.join("\n")
        end

        def olist_style(style)
          return "alphabet" if style == "loweralpha"
          return "roman" if style == "lowerroman"
          return "roman_upper" if style == "upperroman"
          return "alphabet_upper" if style == "upperalpha"
          return style
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
            Validate::style(dt, dt.text)
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
            Validate::style(dd, dd.text)
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
              xml_ul.annotation **attr_code(id: i + 1) do |xml_li|
                Validate::style(item, item.text)
                xml_li << item.text
              end
            end
          end.join("\n")
        end
      end
    end
  end
end
