module Asciidoctor
  module ISO
    module Cleanup
      # currently references cannot contain commas!
      # extending localities to cover ISO referencing
      LOCALITY_REGEX_STR = <<~REGEXP.freeze
        ^((?<locality>section|clause|part|paragraph|chapter|page|
                      table|annex|figure|example|note|formula|
                      locality:[^ \\t\\n\\r:,]+)\\s+
               (?<ref>[^ \\t\\n,:-]+)(-(?<to>[^ \\t\\n,:-]+))?|
          (?<locality2>whole|locality:[^ \\t\\n\\r:,]+))[,:]?\\s*
         (?<text>.*)$
      REGEXP
      LOCALITY_RE = Regexp.new(LOCALITY_REGEX_STR.gsub(/\s/, ""),
                               Regexp::IGNORECASE | Regexp::MULTILINE)

      def extract_localities(x)
        text = x.children.first.remove.text
        while (m = LOCALITY_RE.match text)
          ref = m[:ref] ? "<referenceFrom>#{m[:ref]}</referenceFrom>" : ""
          refto = m[:to] ? "<referenceTo>#{m[:to]}</referenceTo>" : ""
          loc = m[:locality]&.downcase || m[:locality2]&.downcase
          x.add_child("<locality type='#{loc}'>#{ref}#{refto}</locality>")
          text = m[:text]
        end
        x.add_child(text)
      end

      def xref_to_eref(x)
        x["bibitemid"] = x["target"]
        x["citeas"] = @anchors&.dig(x["target"], :xref) ||
          warn("ISO: #{x['target']} is not a real reference!")
        x.delete("target")
        extract_localities(x) unless x.children.empty?
      end

      def xref_cleanup(xmldoc)
        xmldoc.xpath("//xref").each do |x|
          if refid? x["target"]
            x.name = "eref"
            xref_to_eref(x)
          else
            x.delete("type")
          end
        end
      end

      # allows us to deal with doc relation localities,
      # temporarily stashed to "bpart"
      def bpart_cleanup(xmldoc)
        xmldoc.xpath("//relation/bpart").each do |x|
          extract_localities(x)
          x.replace(x.children)
        end
      end

      def quotesource_cleanup(xmldoc)
        xmldoc.xpath("//quote/source | //terms/source").each do |x|
          xref_to_eref(x)
        end
      end

      def origin_cleanup(xmldoc)
        xmldoc.xpath("//origin").each do |x|
          x["citeas"] = @anchors&.dig(x["bibitemid"], :xref) ||
            warn("ISO: #{x['bibitemid']} is not a real reference!")
          extract_localities(x) unless x.children.empty?
        end
      end

      # move ref before p
      def ref_cleanup(xmldoc)
        xmldoc.xpath("//p/ref").each do |r|
          parent = r.parent
          parent.previous = r.remove
        end
      end

      def normref_cleanup(xmldoc)
        q = "//references[title = 'Normative References']"
        r = xmldoc.at(q) || return
        r.elements.each do |n|
          n.remove unless ["title", "bibitem"].include? n.name
        end
      end

      def format_ref(ref, isopub)
        return ref if isopub
        return "[#{ref}]" if /^\d+$/.match?(ref) && !/^\[.*\]$/.match?(ref)
        ref
      end

      ISO_PUBLISHER_XPATH =
        "./contributor[role/@type = 'publisher']/"\
        "organization[abbreviation = 'ISO' or abbreviation = 'IEC' or "\
        "name = 'International Organization for Standardization' or "\
        "name = 'International Electrotechnical Commission']".freeze

      def date_range(date)
        from = date.at("./from")
        to = date.at("./to")
        on = date.at("./on")
        return on.text if on
        ret = "#{from.text}&ndash;"
        ret += to.text if to
        ret
      end

      def reference_names(xmldoc)
        xmldoc.xpath("//bibitem[not(ancestor::bibitem)]").each do |ref|
          isopub = ref.at(ISO_PUBLISHER_XPATH)
          docid = ref.at("./docidentifier")
          date = ref.at("./date[@type = 'published']")
          reference = format_ref(docid.text, isopub)
          reference += ": #{date_range(date)}" if date && isopub
          @anchors[ref["id"]] = { xref: reference }
        end
      end
    end
  end
end
