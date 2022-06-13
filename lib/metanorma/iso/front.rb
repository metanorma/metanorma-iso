require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require_relative "front_id"

module Metanorma
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

      def metadata_subdoctype(node, xml)
        super
        a = node.attr("horizontal") and xml.horizontal a
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
            c.organization do |a|
              organization(a, p, false, node, !node.attr("publisher"))
            end
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "ISO"
        csv_split(publishers).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization do |a|
              organization(a, p, true, node, !node.attr("publisher"))
            end
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("copyright-holder") || node.attr("publisher") ||
          "ISO"
        csv_split(publishers).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization do |o|
                organization(
                  o, p, true, node,
                  !(node.attr("copyright-holder") || node.attr("publisher"))
                )
              end
            end
          end
        end
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        xml.status do |s|
          s.stage stage, **attr_code(abbreviation: cover_stage_abbr(node))
          s.substage substage
          node.attr("iteration") && (s.iteration node.attr("iteration"))
        end
      end

      def metadata_committee(node, xml)
        metadata_editorial_committee(node, xml)
        metadata_approval_committee(node, xml)
      end

      def metadata_editorial_committee(node, xml)
        xml.editorialgroup do |a|
          %w(technical-committee subcommittee workgroup).each do |v|
            node.attr("#{v}-number") and committee_component(v, node, a)
          end
          node.attr("secretariat") and a.secretariat(node.attr("secretariat"))
        end
      end

      def metadata_approval_committee(node, xml)
        types = metadata_approval_committee_types(node)
        xml.approvalgroup do |a|
          metadata_approval_agency(a, node.attr("approval-agency")
            &.split(%r{[/,;]}))
          types.each do |v|
            node.attr("#{v}-number") and committee_component(v, node, a)
          end
        end
      end

      def metadata_approval_committee_types(node)
        types = %w(technical-committee subcommittee workgroup)
        node.attr("approval-technical-committee-number") and
          types = %w(approval-technical-committee approval-subcommittee
                     approval-workgroup)
        types
      end

      def metadata_approval_agency(xml, list)
        list = ["ISO"] if list.nil? || list.empty?
        list.each do |v|
          xml.agency v
        end
      end

      def title_intro(node, xml, lang, at)
        return unless node.attr("title-intro-#{lang}")

        xml.title(**attr_code(at.merge(type: "title-intro"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(node.attr("title-intro-#{lang}"))
        end
      end

      def title_main(node, xml, lang, at)
        xml.title **attr_code(at.merge(type: "title-main")) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(node.attr("title-main-#{lang}"))
        end
      end

      def title_part(node, xml, lang, at)
        return unless node.attr("title-part-#{lang}")

        xml.title(**attr_code(at.merge(type: "title-part"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(node.attr("title-part-#{lang}"))
        end
      end

      def title_amd(node, xml, lang, at)
        return unless node.attr("title-amendment-#{lang}")

        xml.title(**attr_code(at.merge(type: "title-amd"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(
            node.attr("title-amendment-#{lang}"),
          )
        end
      end

      def title_full(node, xml, lang, at)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}")
        amd = node.attr("title-amendment-#{lang}")
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        title = "#{title} -- #{amd}" if amd && @amd
        xml.title **attr_code(at.merge(type: "main")) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(title)
        end
      end

      def title(node, xml)
        %w(en ru fr).each do |lang|
          at = { language: lang, format: "text/plain" }
          title_full(node, xml, lang, at)
          title_intro(node, xml, lang, at)
          title_main(node, xml, lang, at)
          title_part(node, xml, lang, at)
          title_amd(node, xml, lang, at) if @amd
        end
      end

      def relaton_relations
        super + %w(obsoletes successor-of manifestation-of related
                   annotation-of)
      end

      def relaton_relation_descriptions
        super.merge(
          "amends" => "updates", "revises" => "updates",
          "replaces" => "obsoletes",
          "supersedes" => "obsoletes",
          "corrects" => "updates",
          "informatively-cited-in" => "isCitedIn",
          "informatively-cites" => "cites",
          "normatively-cited in" => "isCitedIn",
          "normatively-cites" => "cites",
          "identical-adopted-from" => "adoptedFrom",
          "modified-adopted-from" => "adoptedFrom",
          "related-directive" => "related",
          "related-mandate" => "related"
        )
      end
    end
  end
end
