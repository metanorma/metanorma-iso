require "pp"
module Asciidoctor
  module ISO
    module Lists
      def li(xml_ul, item)
        xml_ul.li do |xml_li|
          style(item, item.text)
          if item.blocks?
            xml_li.p(**id_attr(item)) { |t| t << item.text }
            xml_li << item.content
          else
            xml_li.p(**id_attr(item)) { |p| p << item.text }
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

      def iso_publisher(t, code)
        t.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |aff|
            aff.name code.gsub(%r{[/ \t].*$}, "")
          end
        end
      end

      def plaintxt
        { format: "text/plain" }
      end

      def ref_attributes(m)
        { id: m[:anchor], type: "standard" }
      end

      def isorefmatches(xml, m)
        xml.bibitem **attr_code(ref_attributes(m)) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier m[:code]
          t.date(m[:year], type: "published") if m[:year]
          iso_publisher(t, m[:code])
        end
      end

      def isorefmatches2(xml, m)
        xml.bibitem **attr_code(ref_attributes(m)) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier m[:code]
          t.date "--", type: "published"
          iso_publisher(t, m[:code])
          t.note(**plaintxt) { |p| p << "ISO DATE: #{m[:fn]}" }
        end
      end

      def isorefmatches3(xml, m)
        xml.bibitem **attr_code(ref_attributes(m)) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier "#{m[:code]}:All Parts"
          t.date(m[:year], type: "published") if m[:year]
          iso_publisher(t, m[:code])
        end
      end

      def refitem(xml, item, node)
        m = NON_ISO_REF.match(item) ||
          (Utils::warning(node, "no anchor on reference", item) && return)
        xml.bibitem **attr_code(id: m[:anchor]) do |t|
          t.formattedref **{ format: "application/x-isodoc+xml" } do |i|
            i << ref_normalise_no_format(m[:text])
          end
          code = m[:code]
          t.docidentifier(/^\d+$/.match?(code) ? "[#{code}]" : code)
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
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9-]+)(:(?<year>[0-9]+))?\]</ref>,?\s
      (?<text>.*)$}xm

      ISO_REF_NO_YEAR = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9-]+):--\]</ref>,?\s?
      <fn[^>]*>\s*<p>(?<fn>[^\]]+)</p>\s*</fn>,?\s?(?<text>.*)$}xm

      ISO_REF_ALL_PARTS = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9]+)(:(?<year>[0-9]+))?\s
      \(all\sparts\)\]</ref>,?\s
      (?<text>.*)$}xm

      NON_ISO_REF = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>[^\]]+)\]</ref>,?\s
      (?<text>.*)$}xm

      NORM_ISO_WARN = "non-ISO/IEC reference not expected as normative".freeze

      def reference1_matches(item)
        matched = ISO_REF.match item
        matched2 = ISO_REF_NO_YEAR.match item
        matched3 = ISO_REF_ALL_PARTS.match item
        [matched, matched2, matched3]
      end

      def reference1(node, item, xml, normative)
        matched, matched2, matched3 = reference1_matches(item)
        if matched3.nil? && matched2.nil? && matched.nil?
          refitem(xml, item, node)
        elsif !matched.nil? then isorefmatches(xml, matched)
        elsif !matched2.nil? then isorefmatches2(xml, matched2)
        elsif !matched3.nil? then isorefmatches3(xml, matched3)
        end
        if matched3.nil? && matched2.nil? && matched.nil? && normative
          Utils::warning(node, NORM_ISO_WARN, item)
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
          style(dd, dd.text) if dd.text?
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
              style(item, item.text)
              xml_li.p { |p| p << item.text }
            end
          end
        end.join("\n")
      end
    end
  end
end
