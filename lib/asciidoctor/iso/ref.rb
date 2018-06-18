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
          t.docidentifier "#{m[:code]}"
          if m.named_captures.has_key?("year")
            t.date(**{ type: "published" }) { |d| set_date_range(d, m[:year]) }
          end
          iso_publisher(t, m[:code])
          t.allParts "true"
        end
      end

# --- ISOBIB
      def fetch_ref_err(code, year, missed_years)
        id = year ? "#{code}:#{year}" : code
        warn "WARNING: no match found on the ISO website for #{id}. "\
          "The code must be exactly like it is on the website."
        warn "(There was no match for #{year}, though there were matches "\
          "found for #{missed_years.join(', ')}.)" unless missed_years.empty?
        if /\d-\d/.match? code
          warn "The provided document part may not exist, or the document "\
            "may no longer be published in parts."
        else
          warn "If you wanted to cite all document parts for the reference, "\
            "use \"#{code} (all parts)\".\nIf the document is not a standard, "\
            "use its document type abbreviation (TS, TR, PAS, Guide)."
        end
        nil
      end

      def fetch_pages(s, n)
        workers = WorkersPool.new n
        workers.worker { |w| { i: w[:i], hit: w[:hit].fetch } }
        s.each_with_index { |hit, i| workers << { i: i, hit: hit } }
        workers.end
        workers.result.sort { |x, y| x[:i] <=> y[:i] }.map { |x| x[:hit] }
      end

      def isobib_search_filter(code)
      docidrx = %r{^(ISO|IEC)[^0-9]*\s[0-9-]+}
      corrigrx = %r{^(ISO|IEC)[^0-9]*\s[0-9-]+:[0-9]+/}
        warn "fetching #{code}..."
        result = Isobib::IsoBibliography.search(code)
        result.first.select do |i| 
          i.hit["title"] &&
          i.hit["title"].match(docidrx).to_s == code &&
            !corrigrx.match?(i.hit["title"])
        end 
      end

      def iev
        Nokogiri::XML.fragment(<<~"END")
          <bibitem type="international-standard" id="IEV">
  <title format="text/plain" language="en" script="Latn">Electropedia: 
  The World's Online Electrotechnical Vocabulary</title>
  <source type="src">http://www.electropedia.org</source>
  <docidentifier>IEV</docidentifier>
  <date type="published"> <on>#{Date.today.year}</on> </date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
      <uri>www.iec.ch</uri>
    </organization>
  </contributor>
  <language>en</language> <language>fr</language>
  <script>Latn</script>
  <copyright>
    <from>#{Date.today.year}</from>
    <owner>
      <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
      <uri>www.iec.ch</uri>
      </organization>
    </owner>
  </copyright>
  <relation type="updates">
    <bibitem>
      <formattedref>IEC 60050</formattedref>
    </bibitem>
  </relation>
</bibitem>
        END
      end

      # Sort through the results from Isobib, fetching them three at a time,
      # and return the first result that matches the code,
      # matches the year (if provided), and which # has a title (amendments do not).
      # Only expects the first page of results to be populated.
      # Does not match corrigenda etc (e.g. ISO 3166-1:2006/Cor 1:2007)
      # If no match, returns any years which caused mismatch, for error reporting
      def isobib_results_filter(result, year)
        missed_years = []
        result.each_slice(3) do |s| # ISO website only allows 3 connections
          fetch_pages(s, 3).each_with_index do |r, i|
            return { ret: r } if !year
            r.dates.select { |d| d.type == "published" }.each do |d|
              return { ret: r } if year.to_i == d.on.year
              missed_years << d.on.year
            end
          end
        end
        { years: missed_years }
      end

      def isobib_get1(code, year, opts)
        return iev if code.casecmp? "IEV"
        result = isobib_search_filter(code) or return nil
        ret = isobib_results_filter(result, year)
        return ret[:ret] if ret[:ret]
        fetch_ref_err(code, year, ret[:years])
      end

      def isobib_get(code, year, opts)
        code += "-1" if opts[:all_parts]
        ret = isobib_get1(code, year, opts)
        return nil if ret.nil?
        ret.to_most_recent_reference if !year
        ret.to_all_parts if opts[:all_parts]
        ret.to_xml
      end

      # --- ISOBIB

      def iso_id(code, year, all_parts)
        ret = code
        ret += ":#{year}" if year
        ret += " (all parts)" if all_parts
        ret
      end

      def fetch_ref1(code, year, opts)
        id = iso_id(code, year, opts[:all_parts])
        return nil if @bibliodb.nil? # signals we will not be using isobib
        @bibliodb[id] = isobib_get(code, year, opts) unless @bibliodb[id]
        @local_bibliodb[id] = @bibliodb[id] if !@local_bibliodb.nil? &&
          !@local_bibliodb[id]
        return @local_bibliodb[id] unless @local_bibliodb.nil?
        @bibliodb[id]
      end

      def fetch_ref(xml, code, year, **opts)
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
