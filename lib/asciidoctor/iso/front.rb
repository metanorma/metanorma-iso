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
        xml.docidentifier do |i|
          i.project_number node.attr("docnumber"),
            **attr_code(part: node.attr("partnumber"))
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

      def author_component(compname, node, out)
        out.send compname.gsub(/-/, "_"), node.attr(compname),
          **attr_code(number: node.attr("#{compname}-number"))
      end

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "ISO"
            author_component("technical-committee", node, a)
            author_component("subcommittee", node, a)
            author_component("workgroup", node, a)
            node.attr("secretariat") && a.secretariat(node.attr("secretariat"))
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name "ISO"
          end
        end
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "ISO"
            end
          end
        end
      end

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage ( node.attr("docstage") || "60" )
          s.substage ( node.attr("docsubstage") || "60" )
        end
      end

      def metadata(node, xml)
        title node, xml
        metadata_id(node, xml)
        metadata_author(node, xml)
        metadata_publisher(node, xml)
        xml.language node.attr("language")
        xml.script "Latn"
        metadata_status(node, xml)
        metadata_copyright(node, xml)
      end

      def title(node, xml)
        ["en", "fr"].each do |lang|
          xml.title do |t|
            at = { language: lang, format: "plain" }
            node.attr("title-intro-#{lang}") and
              t.title_intro **attr_code(at) do |t|
              t << node.attr("title-intro-#{lang}")
            end
            t.title_main **attr_code(at) do |t1|
              t1 << node.attr("title-main-#{lang}")
            end
            node.attr("title-part-#{lang}") and
              t.title_part **attr_code(at) do |t1|
              t1 << node.attr("title-part-#{lang}")
            end
          end
        end
      end
    end
  end
end
