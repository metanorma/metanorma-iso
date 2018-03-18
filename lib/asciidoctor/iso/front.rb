require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module Front
      def metadata_id(node, xml)
        part, subpart = node&.attr("partnumber")&.split(/-/)
        xml.docidentifier do |i|
          i.project_number node.attr("docnumber"),
            **attr_code(part: part, subpart: subpart)
          if node.attr("tc-docnumber")
            i.tc_document_number node.attr("tc-docnumber")
          end
        end
      end

      def metadata_version(node, xml)
        xml.version do |v|
          v.edition node.attr("edition") if node.attr("edition")
          v.revision_date node.attr("revdate") if node.attr("revdate")
          v.draft node.attr("draft") if node.attr("draft")
        end
      end

      def committee_component(compname, node, out)
        out.send compname.gsub(/-/, "_"), node.attr(compname),
          **attr_code(number: node.attr("#{compname}-number"),
                      type: node.attr("#{compname}-type"))
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

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage (node.attr("docstage") || "60")
          s.substage (node.attr("docsubstage") || "60")
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

      def metadata(node, xml)
        title node, xml
        metadata_id(node, xml)
        metadata_author(node, xml)
        metadata_publisher(node, xml)
        xml.language node.attr("language")
        xml.script (node.attr("script") || "Latn")
        metadata_status(node, xml)
        metadata_copyright(node, xml)
        metadata_committee(node, xml)
      end

      def title_intro(node, t, lang, at)
        return unless node.attr("title-intro-#{lang}")
        t.title_intro(**attr_code(at)) do |t1|
          t1 << node.attr("title-intro-#{lang}")
        end
      end

      def title_main(node, t, lang, at)
        t.title_main **attr_code(at) do |t1|
          t1 << node.attr("title-main-#{lang}")
        end
      end

      def title_part(node, t, lang, at)
        return unless node.attr("title-part-#{lang}")
        t.title_part(**attr_code(at)) do |t1|
          t1 << node.attr("title-part-#{lang}")
        end
      end

      def title(node, xml)
        ["en", "fr"].each do |lang|
          xml.title do |t|
            at = { language: lang, format: "text/plain" }
            title_intro(node, t, lang, at)
            title_main(node, t, lang, at)
            title_part(node, t, lang, at)
          end
        end
      end
    end
  end
end
