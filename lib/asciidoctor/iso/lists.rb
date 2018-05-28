require "pp"
require "isobib"

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

      def iso_publisher(t, code)
        code.sub(/ .*$/, "").split(/\//).each do |abbrev|
          t.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization do |org|
              organization(org, abbrev)
            end
          end
        end
      end

      def plaintxt
        { format: "text/plain" }
      end

      def ref_attributes(m)
        { id: m[:anchor], type: "standard" }
      end

      def set_date_range(date, text)
        matched = /^(?<from>[0-9]+)(-+(?<to>[0-9]+))?$/.match text
        return unless matched[:from]
        if matched[:to]
          date.from matched[:from]
          date.to matched[:to]
        else
          date.on matched[:from]
        end
      end

      def isorefmatches(xml, m)
        ref = fetch_ref xml, m[:code]
        return ref if ref
        xml.bibitem **attr_code(ref_attributes(m)) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier m[:code]
          m[:year] and t.date **{ type: "published" } do |d|
            set_date_range(d, m[:year])
          end
          iso_publisher(t, m[:code])
        end
      end

      def isorefmatches2(xml, m)
        ref = fetch_ref xml, m[:code], no_year: true, note: m[:fn]
        return ref if ref
        xml.bibitem **attr_code(ref_attributes(m)) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier m[:code]
          t.date **{ type: "published" } do |d|
            d.on "--"
          end
          iso_publisher(t, m[:code])
          t.note(**plaintxt) { |p| p << "ISO DATE: #{m[:fn]}" }
        end
      end

      def isorefmatches3(xml, m)
        ref = fetch_ref xml, m[:code], all_parts: true
        return ref if ref
        xml.bibitem(**attr_code(ref_attributes(m))) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier "#{m[:code]}:All Parts"
          if m.named_captures.has_key?("year")
            t.date(**{ type: "published" }) { |d| set_date_range(d, m[:year]) }
          end
          iso_publisher(t, m[:code])
        end
      end

      def fetch_ref(xml, code, **opts)
        result = Isobib::IsoBibliography.search(code)
        hit = result&.first&.first
        coderegex = %r{^(ISO|IEC)[^0-9]*\s[0-9-]+}
        if hit && hit.hit["title"]&.match(coderegex)&.to_s == code
          hit.to_xml xml, opts
        end
      rescue Algolia::AlgoliaProtocolError
        # Render reference without an Internet connection.
        nil
      end

      # TODO: alternative where only title is available
      def refitem(xml, item, node)
        unless m = NON_ISO_REF.match(item)
          Utils::warning(node, "no anchor on reference", item)
          return
        end
        xml.bibitem **attr_code(id: m[:anchor]) do |t|
          t.formattedref **{ format: "application/x-isodoc+xml" } do |i|
            i << ref_normalise_no_format(m[:text])
          end
          t.docidentifier(/^\d+$/.match?(m[:code]) ? "[#{m[:code]}]" : m[:code])
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
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9-]+)(:(?<year>[0-9][0-9-]+))?\]</ref>,?\s
      (?<text>.*)$}xm

      ISO_REF_NO_YEAR = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9-]+):--\]</ref>,?\s?
      <fn[^>]*>\s*<p>(?<fn>[^\]]+)</p>\s*</fn>,?\s?(?<text>.*)$}xm

      ISO_REF_ALL_PARTS = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9]+)(:(?<year>[0-9][0-9-]+))?\s
      \(all\sparts\)\]</ref>,?\s
      (?<text>.*)$}xm

      NON_ISO_REF = %r{^<ref\sid="(?<anchor>[^"]+)">
      \[(?<code>[^\]]+)\]</ref>,?\s
      (?<text>.*)$}xm

      # @param item [String]
      # @return [Array<MatchData>]
      def reference1_matches(item)
        matched = ISO_REF.match item
        matched2 = ISO_REF_NO_YEAR.match item
        matched3 = ISO_REF_ALL_PARTS.match item
        [matched, matched2, matched3]
      end

      # @param node [Asciidoctor::List]
      # @param item [String]
      # @param xml [Nokogiri::XML::Builder]
      def reference1(node, item, xml)
        matched, matched2, matched3 = reference1_matches(item)
        if matched3.nil? && matched2.nil? && matched.nil?
          refitem(xml, item, node)
        # elsif fetch_ref(matched3 || matched2 || matched, xml)
        elsif !matched.nil? then isorefmatches(xml, matched)
        elsif !matched2.nil? then isorefmatches2(xml, matched2)
        elsif !matched3.nil? then isorefmatches3(xml, matched3)
        end
      end

      def reference(node)
        noko do |xml|
          node.items.each do |item|
            reference1(node, item.text, xml)
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
