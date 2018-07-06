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
        ref.parent.elements.last["id"] = id
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
        hasyr =  m.named_captures.has_key?("year")
        ref = fetch_ref xml, m[:code], hasyr ? m[:year] : nil, all_parts: true
        return use_my_anchor(ref, m[:anchor]) if ref
        xml.bibitem(**attr_code(ref_attributes(m))) do |t|
          t.title(**plaintxt) { |i| i << ref_normalise(m[:text]) }
          t.docidentifier "#{m[:code]}"
          hasyr and
            t.date(**{ type: "published" }) { |d| set_date_range(d, m[:year]) }
          iso_publisher(t, m[:code])
          t.allParts "true"
        end
      end

      def iso_id(code, year, all_parts)
        ret = code
        ret += ":#{year}" if year
        ret += " (all parts)" if all_parts
        ret
      end

      # => , because the hash is imported from JSON
      def new_bibcache_entry(code, year, opts)
        { "fetched" => Date.today, 
          "bib" => Isobib::IsoBibliography.get(code, year, opts) }
      end

      # if cached reference is undated, expire it after 60 days
      def is_valid_bibcache_entry?(x, year)
        x && x.is_a?(Hash) && x&.has_key?("bib") && x&.has_key?("fetched") &&
          (year || Date.today - Date.iso8601(x["fetched"]) < 60)
      end

      def check_bibliocache(code, year, opts)
        id = iso_id(code, year, opts[:all_parts])
        return nil if @bibdb.nil? # signals we will not be using isobib
        @bibdb[id] = nil unless is_valid_bibcache_entry?(@bibdb[id], year)
        @bibdb[id] ||= new_bibcache_entry(code, year, opts)
        @local_bibdb[id] = @bibdb[id] if !@local_bibdb.nil? &&
          !is_valid_bibcache_entry?(@local_bibdb[id], year)
        return @local_bibdb[id]["bib"] unless @local_bibdb.nil?
        @bibdb[id]["bib"]
      end

      def fetch_ref(xml, code, year, **opts)
        hit = check_bibliocache(code, year, opts)
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
      \[(?<code>(ISO|IEC)[^0-9]*\s[0-9-]+|IEV)
      (:(?<year>[0-9][0-9-]+))?\]</ref>,?\s
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

      def bibliocache_name(global)
        global ?  "#{Dir.home}/.relaton-bib.json" :
          "#{@filename}.relaton.json"
      end

      # if returns nil, then biblio caching is disabled, and so is use of isobib
      def open_cache_biblio(node, global)
        # return nil # disabling for now
        return nil if node.attr("no-isobib")
        return {} if @no_isobib_cache
        filename = bibliocache_name(global)
        system("rm -f #{filename}") if node.attr("flush-caches")
        biblio = {}
        if Pathname.new(filename).file?
          File.open(filename, "r") do |f|
            biblio = JSON.parse(f.read)
          end
        end
        biblio
      end

      def save_cache_biblio(biblio, global)
        return if biblio.nil? || @no_isobib_cache
        filename = bibliocache_name(global)
        File.open(filename, "w") do |b|
          b << biblio.to_json
        end
      end
    end
  end
end
