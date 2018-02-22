module Asciidoctor
  module ISO
    module Cleanup
      # currently references cannot contain commas!
      # extending localities to cover ISO referencing
      LOCALITY_REGEX_STR = <<~REGEXP.freeze
        ^((?<locality>section|clause|part|paragraph|chapter|page|
                      table|annex|figure|example|note|formula)\\s+
               (?<ref>[^ \\t\\n,:-]+)(-(?<to>[^ \\t\\n,:-]+))?|
          (?<locality>whole))[,:]?\\s*
         (?<text>.*)$
      REGEXP
      LOCALITY_RE = Regexp.new(LOCALITY_REGEX_STR.gsub(/\s/, ""),
                               Regexp::IGNORECASE | Regexp::MULTILINE)

      def extract_localities(x)
        text = x.children.first.remove.text
        m = LOCALITY_RE.match text
        while !m.nil?
          ref = m[:ref] ? "<referenceFrom>#{m[:ref]}</referenceFrom>" : ""
          refto = m[:to] ? "<referenceTo>#{m[:to]}</referenceTo>" : ""
          locality = m[:locality].downcase
          x.add_child("<locality type='#{locality}'>#{ref}#{refto}</locality>")
          text = m[:text]
          m = LOCALITY_RE.match text
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
          if is_refid? x["target"]
            x.name = "eref"
            xref_to_eref(x)
          else
            x.delete("type")
          end
        end
      end

      # allows us to deal with doc relation localities, temporarily stashed to "bpart"
      def bpart_cleanup(xmldoc)
        xmldoc.xpath("//relation/bibitem/bpart").each do |x|
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

      def isotitle_cleanup(xmldoc)
        # Remove italicised ISO titles
        xmldoc.xpath("//isotitle").each do |a|
          if a.elements.size == 1 && a.elements[0].name == "em"
            a.children = a.elements[0].children
          end
        end
      end

      def ref_cleanup(xmldoc)
        # move ref before p
        xmldoc.xpath("//p/ref").each do |r|
          parent = r.parent
          parent.previous = r.remove
        end
      end

      def normref_cleanup(xmldoc)
        q = "//references[title = 'Normative References']"
        r = xmldoc.at(q)
        r.elements.each do |n|
          n.remove unless ["title", "bibitem"].include? n.name
        end
      end

      def format_ref(ref, isopub)
        return ref if isopub
        return "[#{ref}]" if /^\d+$/.match?(ref) && !/^\[.*\]$/.match?(ref)
        ref
      end

      def reference_names(xmldoc)
        xmldoc.xpath("//bibitem").each do |ref|
          isopub = ref.at("./contributor[role/@type = 'publisher']/"\
                          "organization[name = 'ISO']")
          docid = ref.at("./docidentifier")
          date = ref.at("./publisherdate")
          reference = format_ref(docid.text, isopub)
          reference += ": #{date.text}" if date && isopub
          @anchors[ref["id"]] = { xref: reference }
        end
      end
    end
  end
end
