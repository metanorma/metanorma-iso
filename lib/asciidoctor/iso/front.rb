require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require_relative "front_id"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def metadata_ext(node, xml)
        super
        structured_id(node, xml)
        xml.stagename stage_name(get_stage(node), get_substage(node),
                                 doctype(node), node.attr("iteration"))
        @amd && a = node.attr("updates-document-type") and
          xml.updates_document_type a
      end

      def org_abbrev
        { "International Organization for Standardization" => "ISO",
          "International Electrotechnical Commission" => "IEC" }
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "ISO"
        csv_split(publishers).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "ISO"
        csv_split(publishers).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("copyright-holder") || node.attr("publisher") || "ISO"
        csv_split(publishers).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        xml.status do |s|
          s.stage stage, **attr_code(abbreviation: stage_abbr(stage, substage, doctype(node)))
          s.substage substage
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
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(node.attr("title-intro-#{lang}"))
        end
      end

      def title_main(node, t, lang, at)
        t.title **attr_code(at.merge(type: "title-main")) do |t1|
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(node.attr("title-main-#{lang}"))
        end
      end

      def title_part(node, t, lang, at)
        return unless node.attr("title-part-#{lang}")
        t.title(**attr_code(at.merge(type: "title-part"))) do |t1|
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(node.attr("title-part-#{lang}"))
        end
      end

      def title_amd(node, t, lang, at)
        return unless node.attr("title-amendment-#{lang}")
        t.title(**attr_code(at.merge(type: "title-amd"))) do |t1|
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(node.attr("title-amendment-#{lang}"))
        end
      end

      def title_full(node, t, lang, at)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}")
        amd = node.attr("title-amendment-#{lang}")
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        title = "#{title} -- #{amd}" if amd && @amd
        t.title **attr_code(at.merge(type: "main")) do |t1|
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(title)
        end
      end

      def title(node, xml)
        ["en", "fr"].each do |lang|
          at = { language: lang, format: "text/plain" }
          title_full(node, xml, lang, at)
          title_intro(node, xml, lang, at)
          title_main(node, xml, lang, at)
          title_part(node, xml, lang, at)
          title_amd(node, xml, lang, at) if @amd
        end
      end
    end
  end
end
