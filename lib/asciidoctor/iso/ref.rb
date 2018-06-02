require "pp"
require "isobib"

module Asciidoctor
  module ISO
    module Lists
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

      def use_my_anchor(ref, id)
        ref.parent.children.last["id"] = id
        ref
      end

      def isorefmatches(xml, m)
        ref = fetch_ref xml, m[:code], m[:year]
        return use_my_anchor(ref, m[:anchor]) if ref
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
        ref = fetch_ref xml, m[:code], nil, no_year: true, note: m[:fn]
        return use_my_anchor(ref, m[:anchor]) if ref
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
        ref = fetch_ref xml, m[:code], m[:year], all_parts: true
        return use_my_anchor(ref, m[:anchor]) if ref
        xml.bibitem(**attr_code(ref_attributes(m))) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier "#{m[:code]}:All Parts"
          if m.named_captures.has_key?("year")
            t.date(**{ type: "published" }) { |d| set_date_range(d, m[:year]) }
          end
          iso_publisher(t, m[:code])
        end
      end

      def fetch_year_check(hit, code, year, opts)
        ret =nil
        if year.nil? || year.to_i == hit.hit["year"]
          ret = hit.to_xml opts
          @bibliodb[code] = ret if @bibliodb
        else
          warn "WARNING: cited year #{year} does not match year "\
            "#{hit.hit['year']} found on the ISO website for #{code}"
        end
        ret
      end

      def first_with_title(result)
        result.first.each do |x|
          next unless x.hit["title"]
          return x
        end
        return nil
      end

      def first_year_match_hit(result, code, year)
        return first_with_title(result) if year.nil?
        return nil unless result.first && result.first.is_a?(Array)
        coderegex = %r{^(ISO|IEC)[^0-9]*\s[0-9-]+}
        result.first.each do |x|
          next unless x.hit["title"]
          return x if x.hit["title"].match(coderegex).to_s == code &&
            year.to_i == x.hit["year"]
        end
        return first_with_title(result)
      end

      def fetch_ref_err(code)
        warn "WARNING: no match found on the ISO website for #{code}."
        if /\d-\d/.match? code
          warn "The provided document part may not exist, or the document may no longer be published in parts."
        else
          warn "If you wanted to cite all document parts for the reference, use #{code}:All Parts"
        end
      end

      def fetch_ref1(code, year, opts)
        return @bibliodb[code] if @bibliodb[code]
        result = Isobib::IsoBibliography.search(code)
        ret = nil
        hit = first_year_match_hit(result, code, year)
        coderegex = %r{^(ISO|IEC)[^0-9]*\s[0-9-]+}
        if hit && hit.hit["title"]&.match(coderegex)&.to_s == code
          ret = fetch_year_check(hit, code, year, opts)
        else
          fetch_ref_err(code)
        end
        ret
      end

      def fetch_ref(xml, code, year, **opts)
        warn "fetching #{code}..."
        hit = fetch_ref1(code, year, opts)
        return nil if hit.nil?
        xml.parent.add_child(hit)
        xml
      rescue Algolia::AlgoliaProtocolError
        nil # Render reference without an Internet connection.
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

      def bibliocache_name()
        "#{Dir.home}/.asciidoc-iso-biblio-cache.json"
      end

      # if returns nil, then biblio caching is disabled
      def open_cache_biblio(node)
        filename = bibliocache_name()
        system("rm -f #{filename}") if node.attr("flush-caches") == "true"
        biblio = {}
        if Pathname.new(filename).file?
          File.open(filename, "r") do |f|
            biblio = JSON.parse(f.read)
          end
        end
        biblio
      end

      def save_cache_biblio(biblio)
        return if biblio.nil?
        filename = bibliocache_name()
        File.open(filename, "w") do |b|
          b << biblio.to_json
        end
      end
    end
  end
end
