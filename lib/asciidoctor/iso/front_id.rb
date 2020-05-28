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
        "40": "Draft international standard",
        "50": "Final draft international standard",
        "60": "International standard",
        "90": "Review",
        "95": "Withdrawal",
      }.freeze

      def stage_abbr(stage, substage, doctype)
        return nil if stage.to_i > 60
        return "PRF" if stage == "60" && substage == "00"
        ret = STAGE_ABBRS[stage.to_sym]
        ret = "DTS" if ret == "DIS" && %w(technical-report technical-specification).include?(doctype)
        ret = "FDTS" if ret == "FDIS" && %w(technical-report technical-specification).include?(doctype)
        ret
      end

      def stage_name(stage, substage, doctype)
        return "Proof" if stage == "60" && substage == "00"
        ret = STAGE_NAMES[stage.to_sym]
        if %w(technical-report technical-specification).include? doctype
        ret = "Draft technical standard" if ret == "Draft international standard"
        ret = "Final draft technical standard" if ret == "Final draft international standard"
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
        return unless !@amd && node.attr("docnumber") || @amd && node.attr("updates")
        dn = iso_id1(node)
        dn1 = id_stage_prefix(dn, node, false)
        dn2 = id_stage_prefix(dn, node, true)
        xml.docidentifier dn1, **attr_code(type: "iso")
        xml.docidentifier id_langsuffix(dn1, node), **attr_code(type: "iso-with-lang")
        xml.docidentifier id_langsuffix(dn2, node), **attr_code(type: "iso-reference")
      end

      def iso_id1(node)
        if @amd
          dn = node.attr("updates")
          return add_amd_parts(dn, node)
        else
          part, subpart = node&.attr("partnumber")&.split(/-/)
          dn = add_id_parts(node.attr("docnumber"), part, subpart)
        end
      end

      def add_amd_parts(dn, node)
        a = node.attr("amendment-number")
        c = node.attr("corrigendum-number")
        case node.attr("doctype")
        when "amendment"
          "#{dn}/Amd.#{node.attr('amendment-number')}"
        when "technical corrigendum"
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
            **attr_code(part: part, subpart: subpart, amendment: node.attr("amendment-number"),
                        corrigendum: node.attr("corrigendum-number"), origyr: node.attr("created-date"))
        end
      end

      def add_id_parts(dn, part, subpart)
        dn += "-#{part}" if part
        dn += "-#{subpart}" if subpart
        dn
      end

      def id_stage_abbr(stage, substage, node)
        IsoDoc::Iso::Metadata.new("en", "Latn", {}).
          status_abbrev(stage_abbr(stage, substage, node.attr("doctype")),
          substage, node.attr("iteration"),
          node.attr("draft"), node.attr("doctype"))
      end

      def id_stage_prefix(dn, node, force_year)
        stage = get_stage(node)
        substage = get_substage(node)
        typeabbr = get_typeabbr(node)
        if stage && (stage.to_i < 60)
          abbr = id_stage_abbr(stage, substage, node)
          unless abbr.nil? || abbr.empty? # prefixes added in cleanup
            dn = @amd ? dn.sub(/ /, "/#{abbr} ") : "/#{abbr} #{typeabbr}#{dn}"
          end
        elsif typeabbr && !@amd
          dn = "/#{typeabbr}#{dn}"
        end
        if force_year || !(stage && (stage.to_i < 60))
          year = @amd ? (node.attr("copyright-year") || node.attr("updated-date").sub(/-.*$/, "")) :
            node.attr("copyright-year")
          dn += ":#{year}" if year
        end
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
        case node.attr("doctype")
        when "technical-report" then "TR "
        when "technical-specification" then "TS "
        else
          nil
        end
      end
    end
  end
end
