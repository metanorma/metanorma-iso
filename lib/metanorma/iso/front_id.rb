require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "twitter_cldr"

module Metanorma
  module ISO
    class Converter < Standoc::Converter
      STAGE_ABBRS = {
        "00": "PWI",
        "10": "NP",
        "20": "WD",
        "30": "CD",
        "40": "DIS",
        "50": "FDIS",
        "60": "IS",
        "90": "(Review)",
        "95": "(Withdrawal)",
      }.freeze

      STAGE_NAMES = {
        "00": "Preliminary work item",
        "10": "New work item proposal",
        "20": "Working draft",
        "30": "Committee draft",
        "40": "Draft",
        "50": "Final draft",
        "60": "International standard",
        "90": "Review",
        "95": "Withdrawal",
      }.freeze

      def stage_abbr(stage, substage, doctype)
        return nil if stage.to_i > 60

        ret = STAGE_ABBRS[stage.to_sym]
        ret = "PRF" if stage == "60" && substage == "00"
        ret = "AWI" if stage == "10" && substage == "99"
        ret = "AWI" if stage == "20" && substage == "20"
        if %w(amendment technical-corrigendum technical-report
              technical-specification).include?(doctype)
          ret = "D" if stage == "40" && doctype == "amendment"
          ret = "FD" if stage == "50" && %w(amendment technical-corrigendum)
            .include?(doctype)
        end
        ret
      end

      def stage_name(stage, substage, _doctype, iteration = nil)
        return "Proof" if stage == "60" && substage == "00"

        ret = STAGE_NAMES[stage.to_sym]
        if iteration && %w(20 30).include?(stage)
          prefix = iteration.to_i.localize(@lang.to_sym)
            .to_rbnf_s("SpelloutRules", "spellout-ordinal")
          ret = "#{prefix.capitalize} #{ret.downcase}"
        end
        ret
      end

      def metadata_id(node, xml)
        iso_id(node, xml)
        node&.attr("tc-docnumber")&.split(/,\s*/)&.each do |n|
          xml.docidentifier(n, **attr_code(type: "iso-tc"))
        end
        xml.docnumber node&.attr("docnumber")
      end

      def iso_id(node, xml)
        (!@amd && node.attr("docnumber")) || (@amd && node.attr("updates")) or
          return

        dn = iso_id1(node)
        dn1 = id_stage_prefix(dn, node, false)
        dn2 = id_stage_prefix(dn, node, true)
        xml.docidentifier dn1, **attr_code(type: "ISO")
        xml.docidentifier(id_langsuffix(dn1, node),
                          **attr_code(type: "iso-with-lang"))
        xml.docidentifier(id_langsuffix(dn2, node),
                          **attr_code(type: "iso-reference"))
      end

      def iso_id1(node)
        if @amd
          dn = node.attr("updates")
          add_amd_parts(dn, node)
        else
          part, subpart = node&.attr("partnumber")&.split(/-/)
          add_id_parts(node.attr("docnumber"), part, subpart)
        end
      end

      def add_amd_parts(docnum, node)
        case doctype(node)
        when "amendment"
          "#{docnum}/Amd #{node.attr('amendment-number')}"
        when "technical-corrigendum"
          "#{docnum}/Cor.#{node.attr('corrigendum-number')}"
        end
      end

      def id_langsuffix(docnum, node)
        lang = node.attr("language") || "en"
        suffix = case lang
                 when "en" then "(E)"
                 when "fr" then "(F)"
                 when "ru" then "(R)"
                 else
                   "(X)"
                 end
        "#{docnum}#{suffix}"
      end

      def structured_id(node, xml)
        return unless node.attr("docnumber")

        part, subpart = node&.attr("partnumber")&.split(/-/)
        xml.structuredidentifier do |i|
          i.project_number(node.attr("docnumber"), **attr_code(
            part: part, subpart: subpart,
            amendment: node.attr("amendment-number"),
            corrigendum: node.attr("corrigendum-number"),
            origyr: node.attr("created-date")
          ))
        end
      end

      def add_id_parts(docnum, part, subpart)
        docnum += "-#{part}" if part
        docnum += "-#{subpart}" if subpart
        docnum
      end

      def id_stage_abbr(stage, substage, node, bare = false)
        ret = id_stage_abbr1(stage, substage, node, bare)
        if %w(amendment technical-corrigendum technical-report
              technical-specification).include?(doctype(node)) &&
            !%w(D FD).include?(ret)
          ret = "#{ret} "
        end
        ret
      end

      def id_stage_abbr1(stage, substage, node, bare)
        if bare
          IsoDoc::Iso::Metadata.new("en", "Latn", @i18n)
            .status_abbrev(stage_abbr(stage, substage, doctype(node)),
                           substage, nil, nil, doctype(node))
        else
          IsoDoc::Iso::Metadata.new("en", "Latn", @i18n)
            .status_abbrev(stage_abbr(stage, substage, doctype(node)),
                           substage, node.attr("iteration"),
                           node.attr("draft"), doctype(node))
        end
      end

      def cover_stage_abbr(node)
        stage = get_stage(node)
        abbr = id_stage_abbr(get_stage(node), get_substage(node), node, true)
        typeabbr = get_typeabbr(node, true)
        if stage.to_i > 50 || (stage.to_i == 60 && get_substage(node).to_i < 60)
          typeabbr = ""
        end
        "#{abbr}#{typeabbr}".strip
      end

      def id_stage_prefix(docnum, node, force_year)
        stage = get_stage(node)
        typeabbr = get_typeabbr(node)
        if stage && (stage.to_i < 60)
          docnum = unpub_stage_prefix(docnum, stage, typeabbr, node)
        elsif typeabbr == "DIR " then docnum = "#{typeabbr}#{docnum}"
        elsif typeabbr && !@amd then docnum = "/#{typeabbr}#{docnum}"
        end
        (force_year || !(stage && (stage.to_i < 60))) and
          docnum = id_add_year(docnum, node)
        docnum
      end

      def unpub_stage_prefix(docnum, stage, typeabbr, node)
        abbr = id_stage_abbr(stage, get_substage(node), node)
        %w(40 50).include?(stage) && i = node.attr("iteration") and
          itersuffix = ".#{i}"
        return docnum if abbr.nil? || abbr.empty? # prefixes added in cleanup
        return "/#{abbr}#{typeabbr} #{docnum}#{itersuffix}" unless @amd

        a = docnum.split(%r{/})
        a[-1] = "#{abbr}#{a[-1]}#{itersuffix}"
        a.join("/")
      end

      def id_add_year(docnum, node)
        year = node.attr("copyright-year")
        @amd and year ||= node.attr("updated-date")&.sub(/-.*$/, "")
        docnum += ":#{year}" if year
        docnum
      end

      def get_stage(node)
        a = node.attr("status")
        a = node.attr("docstage") if a.nil? || a.empty?
        a = "60" if a.nil? || a.empty?
        a
      end

      def get_substage(node)
        stage = get_stage(node)
        ret = node.attr("docsubstage")
        ret = (stage == "60" ? "60" : "00") if ret.nil? || ret.empty?
        ret
      end

      def get_typeabbr(node, amd = false)
        case doctype(node)
        when "directive" then "DIR "
        when "technical-report" then "TR "
        when "technical-specification" then "TS "
        when "amendment" then (amd ? "Amd " : "")
        when "technical-corrigendum" then (amd ? "Cor " : "")
        end
      end
    end
  end
end
