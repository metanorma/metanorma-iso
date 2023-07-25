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
      def metadata_id(node, xml)
        if id = node.attr("docidentifier")
          xml.docidentifier id, **attr_code(type: "ISO")
        else iso_id(node, xml)
        end
        node.attr("tc-docnumber")&.split(/,\s*/)&.each do |n|
          xml.docidentifier(n, **attr_code(type: "iso-tc"))
        end
        xml.docnumber node.attr("docnumber")
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
        when "publicly-available-specification" then :pas
        when "guide" then :guide
        end
      end

      def iso_id(node, xml)
        (!@amd && node.attr("docnumber")) || (@amd && node.attr("updates")) or
          return
        params = iso_id_params(node)
        iso_id_out(xml, params, true)
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
        if stage
          ret[:stage] = stage
          ret[:stage] == "60.00" and ret[:stage] = :PRF
        end
        ret
      end

      def iso_id_stage(node)
        "#{get_stage(node)}.#{get_substage(node)}"
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
        params.merge!(params2)
        params
      end

      def iso_id_out(xml, params, with_prf)
        xml.docidentifier iso_id_default(params).to_s(with_prf: with_prf),
                          **attr_code(type: "ISO")
        xml.docidentifier iso_id_reference(params)
          .to_s(format: :ref_num_short, with_prf: with_prf),
                          **attr_code(type: "iso-reference")
        xml.docidentifier iso_id_reference(params).urn, **attr_code(type: "URN")
        return if @amd

        xml.docidentifier iso_id_undated(params).to_s(with_prf: with_prf),
                          **attr_code(type: "iso-undated")
        xml.docidentifier iso_id_with_lang(params)
          .to_s(format: :ref_num_long, with_prf: with_prf),
                          **attr_code(type: "iso-with-lang")
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

        part, subpart = node&.attr("partnumber")&.split("-")
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
