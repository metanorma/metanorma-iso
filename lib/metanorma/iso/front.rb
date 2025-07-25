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
        a = node.attr("horizontal") and xml.horizontal a
        metadata_stage(node, xml)
        @amd && a = node.attr("updates-document-type") and
          xml.updates_document_type a
        a = node.attr("fast-track") and xml.send "fast-track", a != "false"
        a = node.attr("price-code") and xml.price_code a
        node.attr("iso-cen-parallel") and xml.iso_cen_parallel true
      end

      STAGE_ERROR = [Pubid::Core::Errors::HarmonizedStageCodeInvalidError,
                     Pubid::Core::Errors::TypeStageParseError,
                     Pubid::Core::Errors::StageInvalidError].freeze

      def metadata_stage(node, xml)
        id = iso_id_default(iso_id_params(node))
        id.stage or return
        if abbr = id.typed_stage_abbrev
          abbr = abbr.to_s.upcase.strip
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
          s.stage stage, **attr_code(abbreviation: abbrev)
          s.substage substage
          i = node.attr("iteration") and s.iteration i
        end
      rescue *STAGE_ERROR
        report_illegal_stage(stage, substage)
      end

      def report_illegal_stage(stage, substage)
        err = "Illegal document stage: #{stage}.#{substage}"
        @log.add("Document Attributes", nil, err)
      end

      def title_component(node, xml, lang, attr, comp)
        t = node.attr("title-#{comp[:name]}-#{lang}") or return
        xml.title(**attr_code(attr.merge(type: "title-#{comp[:abbr]}"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(t)
        end
      end

      def title_intro(node, xml, lang, at)
        t = node.attr("title-intro-#{lang}") or return
        xml.title(**attr_code(at.merge(type: "title-intro"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(t)
        end
      end

      def title_main(node, xml, lang, at)
        xml.title **attr_code(at.merge(type: "title-main")) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(node.attr("title-main-#{lang}"))
        end
      end

      def title_part(node, xml, lang, at)
        t = node.attr("title-part-#{lang}") or return
        xml.title(**attr_code(at.merge(type: "title-part"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(t)
        end
      end

      def title_amd(node, xml, lang, at)
        t = node.attr("title-amendment-#{lang}") or return
        xml.title(**attr_code(at.merge(type: "title-amd"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(t)
        end
      end

      def title_add(node, xml, lang, at)
        t = node.attr("title-addendum-#{lang}") or return
        xml.title(**attr_code(at.merge(type: "title-add"))) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(t)
        end
      end

      def title_full(node, xml, lang, at)
        title, intro, part, amd, add = title_full_prep(node, lang)
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        title = "#{title} -- #{amd}" if amd
        title = "#{title} -- #{add}" if add
        xml.title **attr_code(at.merge(type: "main")) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(title)
        end
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
          at = { language: lang, format: "text/plain" }
          title1(node, xml, lang, at)
        end
      end

      def title1(node, xml, lang, at)
        title_full(node, xml, lang, at)
        %w(intro main part complementary).each do |w|
          title_component(node, xml, lang, at, { name: w, abbr: w })
        end
        @amd and title_component(node, xml, lang, at,
                                 { name: "amendment", abbr: "amd" })
        node.attr("addendum-number") and
          title_component(node, xml, lang, at,
                          { name: "addendum", abbr: "add" })
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
    end
  end
end
