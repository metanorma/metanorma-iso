require "date"
require "nokogiri"
require "pathname"
require "open-uri"
require "pp"
require_relative "./cleanup_block.rb"

module Asciidoctor
  module ISO
    module Cleanup
      def textcleanup(text)
        text.gsub(/\s+<fn /, "<fn ")
      end

      def cleanup(xmldoc)
        sections_cleanup(xmldoc)
        termdef_cleanup(xmldoc)
        isotitle_cleanup(xmldoc)
        table_cleanup(xmldoc)
        formula_cleanup(xmldoc)
        figure_cleanup(xmldoc)
        ref_cleanup(xmldoc)
        note_cleanup(xmldoc)
        normref_cleanup(xmldoc)
        xref_cleanup(xmldoc)
        para_cleanup(xmldoc)
        callout_cleanup(xmldoc)
        origin_cleanup(xmldoc)
        element_name_cleanup(xmldoc)
        footnote_renumber(xmldoc)
        xmldoc
      end

      def element_name_cleanup(xmldoc)
        xmldoc.traverse { |n| n.name = n.name.gsub(/_/, "-") }
      end

      def callout_cleanup(xmldoc)
        xmldoc.xpath("//sourcecode").each do |x|
          callouts = x.elements.select { |e| e.name == "callout" }
          annotations = x.elements.select { |e| e.name == "annotation" }
          if callouts.size == annotations.size
            callouts.each_with_index do |c, i|
              c["target"] = UUIDTools::UUID.random_create
              annotations[i]["id"] = c["id"]
            end
          else
            warn "#{x["id"]}: mismatch of callouts and annotations"
          end
        end
      end

      def xref_to_eref(x)
        x.name = "eref"
        x["bibitemid"] = x["target"]
        x["citeas"] = @anchors[x["target"]][:xref]
        x.delete("target")
      end

      def xref_cleanup(xmldoc)
        reference_names(xmldoc)
        xmldoc.xpath("//xref").each do |x|
          if is_refid? x["target"]
            xref_to_eref(x)
          else
            x.delete("type")
          end
        end
      end

      def origin_cleanup(xmldoc)
        xmldoc.xpath("//origin").each do |x|
          x["citeas"] = @anchors[x["bibitemid"]][:xref]
          n = x.next_element
          if !n.nil? && n.name == "isosection"
            n.name = "locality"
            n["type"] = "section"
            n.parent = x
          end
        end
      end

      def termdef_warn(text, re, term, msg)
        re.match? text and warn "ISO style: #{term}: #{msg}"
      end

      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./p") or return
          term = t.at("preferred").text
          termdef_warn(para.text, /^(the|a)\b/i, term,
                       "term definition starts with article")
          termdef_warn(para.text, /\.$/i, term,
                       "term definition ends with period")
        end
      end

      def termdef_stem_cleanup(xmldoc)
        xmldoc.xpath("//termdef/p/stem").each do |a|
          if a.parent.elements.size == 1
            # para containing just a stem expression
            t = Nokogiri::XML::Element.new("admitted", xmldoc)
            parent = a.parent
            t.children = a.remove
            parent.replace(t)
          end
        end
      end

      def termdomain_cleanup(xmldoc)
        xmldoc.xpath("//p/domain").each do |a|
          prev = a.parent.previous
          prev.next = a.remove
        end
      end

      def termdefinition_cleanup(xmldoc)
        xmldoc.xpath("//term").each do |d|
          first_child = d.at("./p | ./figure | ./formula") or return
          t = Nokogiri::XML::Element.new("definition", xmldoc)
          first_child.replace(t)
          t << first_child.remove
          d.xpath("./p | ./figure | ./formula").each { |n| t << n.remove }
        end
      end

      def termdef_unnest_cleanup(xmldoc)
        # release termdef tags from surrounding paras
        nodes = xmldoc.xpath("//p/admitted | //p/deprecates")
        while !nodes.empty?
          nodes[0].parent.replace(nodes[0].parent.children)
          nodes = xmldoc.xpath("//p/admitted | //p/deprecates")
        end
      end

      def termdef_cleanup(xmldoc)
        termdef_unnest_cleanup(xmldoc)
        termdef_stem_cleanup(xmldoc)
        termdomain_cleanup(xmldoc)
        termdefinition_cleanup(xmldoc)
        termdef_style(xmldoc)
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
        xmldoc
      end

      ELEMS_ALLOW_NOTES = 
        %w[p formula quote sourcecode example admonition ul ol dl figure]

      # if a note is at the end of a section, it is left alone
      # if a note is followed by a non-note block, 
      # it is moved inside its preceding block
      def note_cleanup(xmldoc)
        q = "//note[following-sibling::*[not(local-name() = 'note')]]"
        xmldoc.xpath(q).each do |n|
          next unless n.ancestors("table").empty?
          prev = n.previous_element or next
          n.parent = prev if ELEMS_ALLOW_NOTES.include? prev.name
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
        return "ISO #{ref}" if isopub
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
