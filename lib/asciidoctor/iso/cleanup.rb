require "date"
require "nokogiri"
require "pathname"
require "open-uri"
require "pp"
require_relative "./cleanup_block.rb"
require_relative "./cleanup_ref.rb"

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
        reference_names(xmldoc)
        xref_cleanup(xmldoc)
        quotesource_cleanup(xmldoc)
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
            warn "#{x['id']}: mismatch of callouts and annotations"
          end
        end
      end

      LOCALITY_REGEX_STR = <<~REGEXP.freeze
        ^((?<locality>section|clause|part|paragraph|chapter|page)\\s+
               (?<ref>\\S+?)|(?<locality>whole))[,:]?\\s*
         (?<text>.*)$
      REGEXP
      LOCALITY_RE = Regexp.new(LOCALITY_REGEX_STR.gsub(/\s/, ""),
                               Regexp::IGNORECASE | Regexp::MULTILINE)

      def termdef_warn(text, re, term, msg)
        re.match?(text) && warn("ISO style: #{term}: #{msg}")
      end

      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./p") || return
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
          first_child = d.at("./p | ./figure | ./formula") || return
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

      ELEMS_ALLOW_NOTES =
        %w[p formula quote sourcecode example admonition ul ol dl figure].freeze

      # if a note is at the end of a section, it is left alone
      # if a note is followed by a non-note block,
      # it is moved inside its preceding block
      def note_cleanup(xmldoc)
        q = "//note[following-sibling::*[not(local-name() = 'note')]]"
        xmldoc.xpath(q).each do |n|
          next unless n.ancestors("table").empty?
          prev = n.previous_element || next
          n.parent = prev if ELEMS_ALLOW_NOTES.include? prev.name
        end
      end
    end
  end
end
