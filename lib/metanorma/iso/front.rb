require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require_relative "front_id"
require_relative "front_contributor"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def metadata_ext(node, xml)
        super
        metadata_ext_iso(node, xml)
      end

      def metadata_ext_iso(node, xml)
        add_noko_elem(xml, "horizontal", node.attr("horizontal"))
        metadata_stage(node, xml)
        @amd and
          add_noko_elem(xml, "updates_document_type",
                        node.attr("updates-document-type"))
        a = node.attr("fast-track") and xml.send "fast-track", a != "false"
        add_noko_elem(xml, "price_code", node.attr("price-code"))
        node.attr("iso-cen-parallel") and xml.iso_cen_parallel true
      end

      STAGE_ERROR = [Pubid::Core::Errors::HarmonizedStageCodeInvalidError,
                     Pubid::Core::Errors::TypeStageParseError,
                     Pubid::Core::Errors::StageInvalidError].freeze

      def metadata_stage(node, xml)
        id = iso_id_default(iso_id_params(node))
        id.stage or return
        if abbr = id.typed_stage_abbrev
          # remove IS: work around breakages in pubid-iso
          abbr = abbr.to_s.upcase.strip.sub(/^IS /, "")
        end
        xml.stagename metadata_stagename(id)&.strip,
                      **attr_code(abbreviation: abbr)
      rescue *STAGE_ERROR
      end

      def metadata_stagename(id)
        if @amd
          id.amendments&.first&.stage&.name ||
            id.corrigendums&.first&.stage&.name
        else
          begin
            id.typed_stage_name
          rescue StandardError
            id.stage&.name
          end
        end
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        abbrev = iso_id_default(iso_id_params(node)).stage&.abbr&.upcase
        xml.status do |s|
          add_noko_elem(s, "stage", stage, **attr_code(abbreviation: abbrev))
          add_noko_elem(s, "substage", substage)
          add_noko_elem(s, "iteration", node.attr("iteration"))
        end
      rescue *STAGE_ERROR
        report_illegal_stage(stage, substage)
      end

      def report_illegal_stage(stage, substage)
        @log.add("ISO_9", nil, params: [stage, substage])
      end

      def title_component(node, xml, lang, comp)
        t = node.attr("title-#{comp[:name]}-#{lang}") or return
        add_title_xml(xml, t, lang, "title-#{comp[:abbr]}")
      end

      def title_full(node, xml, lang)
        title, intro, part, amd, add = title_full_prep(node, lang)
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        title = "#{title} -- #{amd}" if amd
        title = "#{title} -- #{add}" if add
        add_title_xml(xml, title, lang, "main")
      end

      def title_full_prep(node, lang)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}") ||
          node.attr("title-complementary-#{lang}")
        @amd and amd = node.attr("title-amendment-#{lang}")
        node.attr("addendum-number") and
          add = node.attr("title-addendum-#{lang}")
        [title, intro, part, amd, add].map { |x| x&.empty? ? nil : x }
      end

      def title(node, xml)
        %w(en ru fr).each do |lang|
          title1(node, xml, lang)
        end
      end

      def title1(node, xml, lang)
        title_full(node, xml, lang)
        %w(intro main part complementary).each do |w|
          title_component(node, xml, lang, { name: w, abbr: w })
        end
        @amd and title_component(node, xml, lang,
                                 { name: "amendment", abbr: "amd" })
        node.attr("addendum-number") and
          title_component(node, xml, lang,
                          { name: "addendum", abbr: "add" })
        title_nums(node, xml, lang)
      end

      def relaton_relations
        super + %w(obsoletes successor-of manifestation-of related
                   annotation-of has-draft)
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

      def structured_id(node, xml)
        node.attr("docnumber") or return # allow empty node.attr("docnumber")
        xml.structuredidentifier do |i|
          i.project_number(node.attr("docnumber"), **attr_code(
            title_nums_prep(node).merge(
              origyr: node.attr("created-date"),
            ),
          ))
        end
      end
    end
  end
end
