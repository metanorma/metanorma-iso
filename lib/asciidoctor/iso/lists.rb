require "pp"
module Asciidoctor
  module ISO
    module Lists
      def li(xml_ul, item)
        xml_ul.li do |xml_li|
          style(item, item.text)
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
        return reference(node, true) if in_norm_ref
        return reference(node, false) if in_biblio
        noko do |xml|
          xml.ul **id_attr(node) do |xml_ul|
            node.items.each do |item|
              li(xml_ul, item)
            end
          end
        end.join("\n")
      end

      def iso_publisher(t)
        t.publisher **{ role: "publisher" } do |p|
          p.affiliation do |aff|
            aff.name "ISO"
          end
        end
      end

      def isorefmatches(xml, matched)
        ref_attributes = { id: matched[:anchor], type: "standard" }
        xml.bibitem **attr_code(ref_attributes) do |t|
          t.name { |i| i << ref_normalise(matched[:text]) }
          t.publishDate matched[:year] if matched[:year]
          t.docidentifier matched[:code]
          iso_publisher(t)
        end
      end

      def isorefmatches2(xml, matched)
        ref_attributes = { id: matched[:anchor], type: "standard" }
        xml.bibitem **attr_code(ref_attributes) do |t|
          t.name { |i| i << ref_normalise(matched[:text]) }
          t.publishDate "--"
          t.docidentifier matched[:code]
          iso_publisher(t)
          t.note { |p| p << "ISO DATE: #{matched[:fn]}" }
        end
      end

      def isorefmatches3(xml, matched)
        ref_attributes = { id: matched[:anchor], type: "standard" }
        xml.bibitem **attr_code(ref_attributes) do |t|
          t.name { |i| i << ref_normalise(matched[:text]) }
          t.publishDate matched[:year] if matched[:year]
          t.docidentifier "#{matched[:code]}:All Parts"
          iso_publisher(t)
        end
      end

      def refitem(xml, item, node)
        m = NON_ISO_REF.match item
        if m.nil? then Utils::warning(node, "no anchor on reference", item)
        else
          xml.bibitem **attr_code(id: m[:anchor]) do |t|
            t.formatted { |i| i << ref_normalise_no_format(m[:text]) }
            code = m[:code]
            code = "[#{code}]" if /^\d+$?/.match? code
            t.docidentifier code
          end
        end
      end

      def ref_normalise(ref)
        ref.
          # gsub(/&#8201;&#8212;&#8201;/, " -- ").
          gsub(/&amp;amp;/, "&amp;").
          gsub(%r{^<em>(.*)</em>}, "\\1")
      end

      def ref_normalise_no_format(ref)
        ref.
          # gsub(/&#8201;&#8212;&#8201;/, " -- ").
          gsub(/&amp;amp;/, "&amp;")
      end

      ISO_REF = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[ISO\s(?<code>[0-9-]+)(:(?<year>[0-9]+))?\]</ref>,?\s
      (?<text>.*)$}xm

      ISO_REF_NO_YEAR = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[ISO\s(?<code>[0-9-]+):--\]</ref>,?\s?
      <fn[^>]*>\s*<p>(?<fn>[^\]]+)</p>\s*</fn>,?\s?(?<text>.*)$}xm

      ISO_REF_ALL_PARTS = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[ISO\s(?<code>[0-9]+)\s\(all\sparts\)\]</ref>(<p>)?,?\s?
      (?<text>.*)(</p>)?$}xm

      NON_ISO_REF = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>[^\]]+)\]</ref>,?\s
      (?<text>.*)$}xm

      def reference1(node, item, xml, normative)
        matched = ISO_REF.match item
        matched2 = ISO_REF_NO_YEAR.match item
        matched3 = ISO_REF_ALL_PARTS.match item
        if matched3.nil? && matched2.nil? && matched.nil?
          refitem(xml, item, node)
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
          style(dt, dt.text)
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
          style(dd, dd.text)
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
              style(item, item.text)
              xml_li.p { |p| p << item.text }
            end
          end
        end.join("\n")
      end
    end
  end
end
