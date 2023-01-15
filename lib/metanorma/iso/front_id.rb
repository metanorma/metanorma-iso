require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "twitter_cldr"
require "pubid-iso"

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

      def stage_abbr(stage, substage, _doctype)
        return nil if stage.to_i > 60

        ret = STAGE_ABBRS[stage.to_sym]
        ret = "PRF" if stage == "60" && substage == "00"
        ret = nil if stage == "60" && substage != "00"
        ret = "AWI" if stage == "10" && substage == "99"
        ret = "AWI" if stage == "20" && substage == "00"
        ret
      end

      #       def stage_name(stage, substage, _doctype, iteration = nil)
      #         return "Proof" if stage == "60" && substage == "00"
      #
      #         ret = STAGE_NAMES[stage.to_sym]
      #         if iteration && %w(20 30).include?(stage)
      #           prefix = iteration.to_i.localize(@lang.to_sym)
      #             .to_rbnf_s("SpelloutRules", "spellout-ordinal")
      #           ret = "#{prefix.capitalize} #{ret.downcase}"
      #         end
      #         ret
      #       end
      def metadata_id(node, xml)
        iso_id(node, xml)
        node.attr("tc-docnumber")&.split(/,\s*/)&.each do |n|
          xml.docidentifier(n, **attr_code(type: "iso-tc"))
        end
        xml.docnumber node&.attr("docnumber")
      end

      # @param type [nil, :tr, :ts, :amd, :cor, :guide, :dir, :tc, Type] 
      # document's type, eg. :tr, :ts, :amd, :cor, Type.new(:tr)
      def get_typeabbr(node, amd: false)
        node.attr("amendment-number") and return :amd
        node.attr("corrigendum-number") and return :cor
        case doctype(node)
        when "directive" then :dir
        when "technical-report" then :tr
        when "technical-specification" then :ts
        when "guide" then :guide
        else nil
        end
      end

      def iso_id(node, xml)
        (!@amd && node.attr("docnumber")) || (@amd && node.attr("updates")) or
          return
        params = iso_id_params(node)
        iso_id_out(xml, params)
      end

      def iso_id_params(node)
        params = iso_id_params_core(node)
        params2 = iso_id_params_add(node)
        if node.attr("updates")
          orig_id = Pubid::Iso::Identifier::Base.parse(node.attr("updates"))
          orig_id.edition ||= 1
        end
        iso_id_params_resolve(params, params2, node, orig_id)
      end

      # unpublished is for internal use
      def iso_id_params_core(node)
        pub = (node.attr("publisher") || "ISO").split(/[;,]/)
        ret = { number: node.attr("docnumber"),
                part: node.attr("partnumber"),
                language: node.attr("language") || "en",
                type: get_typeabbr(node),
                publisher: pub[0],
                unpublished: /^[0-5]/.match?(get_stage(node)),
                copublisher: pub[1..-1] }.compact
        ret[:copublisher].empty? and ret.delete(:copublisher)
        ret
      end

      def iso_id_params_add(node)
        stage = iso_id_stage(node)

        ret = { number: node.attr("amendment-number") ||
          node.attr("corrigendum-number"),
                year: iso_id_year(node),
                iteration: node.attr("iteration") }.compact
        stage and ret[:stage] = stage
        ret
      end

      def iso_id_stage(node)
        #require "debug"; binding.b
        stage = stage_abbr(get_stage(node), get_substage(node),
                           doctype(node)) or return nil
        harmonised = "#{get_stage(node)}.#{get_substage(node)}"
        harmonised = nil unless /^\d\d\.\d\d/.match?(harmonised)
        { abbr: stage.to_sym, harmonized_code: harmonised }
        #stage.to_sym
        harmonised || stage.to_sym
      end

      def iso_id_year(node)
        node.attr("copyright-year") || node.attr("updated-date")
          &.sub(/-.*$/, "") || Date.today.year
      end

      def iso_id_params_resolve(params, params2, node, orig_id)
        if orig_id && (node.attr("amendment-number") ||
            node.attr("corrigendum-number"))
          params.delete(:unpublished)
          params.delete(:part)
          params2[:base] = orig_id
        end
        #if node.attr("amendment-number") then params[:amendments] = [params2]
        #elsif node.attr("corrigendum-number")
         # params[:corrigendums] = [params2]
        #else 
          params.merge!(params2) 
      #end
        params
      end

      def iso_id_out(xml, params)
        xml.docidentifier iso_id_default(params), **attr_code(type: "ISO")
        xml.docidentifier iso_id_reference(params)
          .to_s(format: :ref_num_long), **attr_code(type: "iso-reference")
        xml.docidentifier iso_id_reference(params).urn, **attr_code(type: "URN")
        return if @amd

        xml.docidentifier iso_id_undated(params),
                          **attr_code(type: "iso-undated")
        xml.docidentifier iso_id_with_lang(params)
          .to_s(format: :ref_num_short), **attr_code(type: "iso-with-lang")
      rescue StandardError => e
        clean_abort("Document identifier: #{e}", xml)
      end

      def iso_id_default(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params1 = if params[:unpublished]
                    params_nolang.dup.tap do |hs|
                      hs.delete(:year)
                    end
                  else params_nolang
                  end
        params1.delete(:unpublished)
        #require "debug"; binding.b
        Pubid::Iso::Identifier.create(**params1)
      end

      def iso_id_undated(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params2 = params_nolang.dup.tap do |hs|
          hs.delete(:year)
          hs.delete(:unpublished)
        end
        Pubid::Iso::Identifier.create(**params2)
      end

      def iso_id_with_lang(params)
        params1 = if params[:unpublished]
                    params.dup.tap do |hs|
                      hs.delete(:year)
                    end
                  else params end
        params1.delete(:unpublished)
        Pubid::Iso::Identifier.create(**params1)
      end

      def iso_id_reference(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        Pubid::Iso::Identifier.create(**params1)
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
    end
  end
end
