require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def metadata_id(node, xml)
        iso_id(node, xml)
        node&.attr("tc-docnumber")&.split(/,\s*/)&.each do |n|
          xml.docidentifier(n, **attr_code(type: "iso-tc"))
        end
        xml.docnumber node&.attr("docnumber")
      end

      def iso_id(node, xml)
        return unless node.attr("docnumber")
        part, subpart = node&.attr("partnumber")&.split(/-/)
        dn = add_id_parts(node.attr("docnumber"), part, subpart)
        dn = id_stage_prefix(dn, node)
        xml.docidentifier dn, **attr_code(type: "iso")
      end

      def metadata_ext(node, xml)
        super
        structured_id(node, xml)
      end

      def structured_id(node, xml)
        return unless node.attr("docnumber")
        part, subpart = node&.attr("partnumber")&.split(/-/)
        xml.structuredidentifier do |i|
          i.project_number node.attr("docnumber"),
            **attr_code(part: part, subpart: subpart)
        end
      end

      def add_id_parts(dn, part, subpart)
        dn += "-#{part}" if part
        dn += "-#{subpart}" if subpart
        dn
      end

      def id_stage_prefix(dn, node)
        stage = get_stage(node)
        substage = get_substage(node)
        if stage && (stage.to_i < 60 || stage.to_i == 60 && substage.to_i < 60)
          abbr = IsoDoc::Iso::Metadata.new("en", "Latn", {}).
            stage_abbrev(stage, substage, node.attr("iteration"), 
                         node.attr("draft"))
          dn = "/#{abbr} #{dn}" # prefixes added in cleanup
        else
          dn += ":#{node.attr("copyright-year")}" if node.attr("copyright-year")
        end
        dn
      end

      def organization(org, orgname)
        if ["ISO",
            "International Organization for Standardization"].include? orgname
          org.name "International Organization for Standardization"
          org.abbreviation "ISO"
        elsif ["IEC",
               "International Electrotechnical Commission"].include? orgname
          org.name "International Electrotechnical Commission"
          org.abbreviation "IEC"
        else
          org.name orgname
        end
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
      end

      def get_substage(node)
        stage = get_stage(node)
        node.attr("docsubstage") || ( stage == "60" ? "60" : "00" )
      end

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage get_stage(node)
          s.substage get_substage(node)
          node.attr("iteration") && (s.iteration node.attr("iteration"))
        end
      end

      def metadata_committee(node, xml)
        xml.editorialgroup do |a|
          committee_component("technical-committee", node, a)
          committee_component("subcommittee", node, a)
          committee_component("workgroup", node, a)
          node.attr("secretariat") && a.secretariat(node.attr("secretariat"))
        end
      end

      def title_intro(node, t, lang, at)
        return unless node.attr("title-intro-#{lang}")
        t.title(**attr_code(at.merge(type: "title-intro"))) do |t1|
          t1 << asciidoc_sub(node.attr("title-intro-#{lang}"))
        end
      end

      def title_main(node, t, lang, at)
        t.title **attr_code(at.merge(type: "title-main")) do |t1|
          t1 << asciidoc_sub(node.attr("title-main-#{lang}"))
        end
      end

      def title_part(node, t, lang, at)
        return unless node.attr("title-part-#{lang}")
        t.title(**attr_code(at.merge(type: "title-part"))) do |t1|
          t1 << asciidoc_sub(node.attr("title-part-#{lang}"))
        end
      end

      def title_full(node, t, lang, at)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}")
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        t.title **attr_code(at.merge(type: "main")) do |t1|
          t1 << asciidoc_sub(title)
        end
      end

      def title(node, xml)
        ["en", "fr"].each do |lang|
          at = { language: lang, format: "text/plain" }
          title_full(node, xml, lang, at)
          title_intro(node, xml, lang, at)
          title_main(node, xml, lang, at)
          title_part(node, xml, lang, at)
        end
      end
    end
  end
end
