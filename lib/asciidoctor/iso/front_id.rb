require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "twitter_cldr"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      STAGE_ABBRS = {
        "00": "PWI",
        "10": "NWIP",
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
        if %w(amendment technical-corrigendum technical-report 
          technical-specification).include?(doctype)
          ret = "NP" if stage == "10"
          ret = "AWI" if stage == "10" && substage == "99"
          ret = "D" if stage == "40" and doctype == "amendment"
          ret = "FD" if stage == "50" and
            %w(amendment technical-corrigendum).include?(doctype)
          ret = "D" if stage == "50" and
            %w(technical-report technical-specification).include?(doctype)
        end
        ret
      end

      def stage_name(stage, substage, doctype, iteration = nil)
        return "Proof" if stage == "60" && substage == "00"
        ret = STAGE_NAMES[stage.to_sym]
        if iteration && %w(20 30).include?(stage)
          prefix  = iteration.to_i.localize(@lang.to_sym).
            to_rbnf_s("SpelloutRules", "spellout-ordinal")
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
        return unless !@amd && node.attr("docnumber") ||
          @amd && node.attr("updates")
        dn = iso_id1(node)
        dn1 = id_stage_prefix(dn, node, false)
        dn2 = id_stage_prefix(dn, node, true)
        xml.docidentifier dn1, **attr_code(type: "ISO")
        xml.docidentifier id_langsuffix(dn1, node),
          **attr_code(type: "iso-with-lang")
        xml.docidentifier id_langsuffix(dn2, node),
          **attr_code(type: "iso-reference")
      end

      def iso_id1(node)
        if @amd
          dn = node.attr("updates")
          return add_amd_parts(dn, node)
        else
          part, subpart = node&.attr("partnumber")&.split(/-/)
          return add_id_parts(node.attr("docnumber"), part, subpart)
        end
      end

      def add_amd_parts(dn, node)
        a = node.attr("amendment-number")
        c = node.attr("corrigendum-number")
        case doctype(node)
        when "amendment"
          "#{dn}/Amd #{node.attr('amendment-number')}"
        when "technical-corrigendum"
          "#{dn}/Cor.#{node.attr('corrigendum-number')}"
        end
      end

      def id_langsuffix(dn, node)
        lang = node.attr("language") || "en"
        suffix = case lang
                 when "en" then "(E)"
                 when "fr" then "(F)"
                 else
                   "(X)"
                 end
        "#{dn}#{suffix}"
      end

      def structured_id(node, xml)
        return unless node.attr("docnumber")
        part, subpart = node&.attr("partnumber")&.split(/-/)
        xml.structuredidentifier do |i|
          i.project_number node.attr("docnumber"),
            **attr_code(part: part, subpart: subpart,
                        amendment: node.attr("amendment-number"),
                        corrigendum: node.attr("corrigendum-number"),
                        origyr: node.attr("created-date"))
        end
      end

      def add_id_parts(dn, part, subpart)
        dn += "-#{part}" if part
        dn += "-#{subpart}" if subpart
        dn
      end

      def id_stage_abbr(stage, substage, node)
        ret = IsoDoc::Iso::Metadata.new("en", "Latn", @i18n).
          status_abbrev(stage_abbr(stage, substage, doctype(node)),
                        substage, node.attr("iteration"),
                        node.attr("draft"), doctype(node))
        if %w(amendment technical-corrigendum amendment
          technical-corrigendum).include?(doctype(node))
          ret = ret + " " unless %w(40 50).include?(stage)
        end
        ret
      end

      def id_stage_prefix(dn, node, force_year)
        stage = get_stage(node)
        typeabbr = get_typeabbr(node)
        if stage && (stage.to_i < 60)
          dn = unpub_stage_prefix(dn, stage, typeabbr, node)
        elsif typeabbr && !@amd then dn = "/#{typeabbr}#{dn}"
        end
        (force_year || !(stage && (stage.to_i < 60))) and
          dn = id_add_year(dn, node)
        dn
      end

      def unpub_stage_prefix(dn, stage, typeabbr, node)
        abbr = id_stage_abbr(stage, get_substage(node), node)
        %w(40 50).include?(stage) && i = node.attr("iteration") and
          itersuffix = ".#{i}"
        return dn if abbr.nil? || abbr.empty? # prefixes added in cleanup
        return "/#{abbr}#{typeabbr} #{dn}#{itersuffix}" unless @amd
        a = dn.split(%r{/})
        a[-1] = "#{abbr}#{a[-1]}#{itersuffix}"
        a.join("/")
      end

      def id_add_year(dn, node)
        year = node.attr("copyright-year")
        @amd and year ||= node.attr("updated-date")&.sub(/-.*$/, "")
        dn += ":#{year}" if year
        dn
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
      end

      def get_substage(node)
        stage = get_stage(node)
        node.attr("docsubstage") || ( stage == "60" ? "60" : "00" )
      end

      def get_typeabbr(node)
        case doctype(node)
        when "technical-report" then "TR "
        when "technical-specification" then "TS "
        else
          nil
        end
      end
    end
  end
end
