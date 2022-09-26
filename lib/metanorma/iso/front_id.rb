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

      def stage_abbr(stage, substage, doctype)
        return nil if stage.to_i > 60

        ret = STAGE_ABBRS[stage.to_sym]
        ret = "PRF" if stage == "60" && substage == "00"
        ret = "AWI" if stage == "10" && substage == "99"
        ret = "AWI" if stage == "20" && substage == "00"
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
        dn = id_stage_prefix(iso_id1(node), node)
        dns = [id_year(dn, node, mode: :default),
               id_year(dn, node, mode: :force),
               id_year(dn, node, mode: :strip)]
        iso_id_out(node, xml, dns)
      end

      def iso_id_out(node, xml, dns)
        xml.docidentifier dns[0], **attr_code(type: "ISO")
        xml.docidentifier dns[2], **attr_code(type: "iso-undated")
        xml.docidentifier(id_langsuffix(dns[0], node),
                          **attr_code(type: "iso-with-lang"))
        xml.docidentifier(id_langsuffix(dns[1], node),
                          **attr_code(type: "iso-reference"))
      end

            def get_typeabbr(node, amd: false)
        case doctype(node)
        when "directive" then "DIR "
        when "technical-report" then "TR "
        when "technical-specification" then "TS "
        when "amendment" then (amd ? "Amd " : "")
        when "technical-corrigendum" then (amd ? "Cor " : "")
        end
      end

=begin
def get_typeabbr(node, amd: false)
        case doctype(node)
        when "directive" then "DIR"
        when "technical-report" then "TR"
        when "technical-specification" then "TS"
        else nil
        end
      end

      def iso_id(node, xml)
        (!@amd && node.attr("docnumber")) || (@amd && node.attr("updates")) or
          return
        stage = id_stage_abbr(get_stage(node), get_substage(node), node, true)&.strip
        stage = nil if %w{IS (Review) (Withdrwal)}.include?(stage.strip)
          urn_stage = "#{get_stage(node)}.#{get_substage(node)}"
pub =  (node.attr("publisher") || "ISO").split(/[;,]/)
        params = {
          number: node.attr("docnumber"), # (@amd ? node.attr("updates") : node.attr("docnumber")),
          part: node.attr("partnumber"),
          language: node.attr("language") || "en",
          type: get_typeabbr(node),
          year: node.attr("copyright-year") || node.attr("updated-date")&.sub(/-.*$/, ""),
          publisher: pub[0],
          copublisher: pub[1..-1],
        }.compact
        if a = node.attr("amendment-number")
          params[:amendments] = { number: a, stage: stage }
          elsif a = node.attr("corrigendum-number")
          params[:corrigendums] = { number: a, stage: stage }
          else
            params.merge!( { stage: stage, urn_stage: urn_stage }.compact )
          end
        iso_id_out(xml, params)
      end

      def iso_id_out(xml, params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        unpub = /^[0-5]/.match?(params[:urn_stage])
        params1 = unpub ? params_nolang.dup.tap { |hs| hs.delete(:year) } : params_nolang
        xml.docidentifier Pubid::Iso::Identifier.new(**params1), **attr_code(type: "ISO")
        params2 = params_nolang.dup.tap { |hs| hs.delete(:year) }
        xml.docidentifier Pubid::Iso::Identifier.new(**params2), **attr_code(type: "iso-undated")
        params1 = unpub ? params.dup.tap { |hs| hs.delete(:year) } : params
        xml.docidentifier(Pubid::Iso::Identifier.new(**params1),
                          **attr_code(type: "iso-with-lang"))
        warn params
        warn "Generated: #{Pubid::Iso::Identifier.new(**params).to_s}"
        xml.docidentifier(Pubid::Iso::Identifier.new(**params),
                          **attr_code(type: "iso-reference"))
      end
=end

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
          IsoDoc::Iso::Metadata.new("en", "Latn", nil, @i18n)
            .status_abbrev(stage_abbr(stage, substage, doctype(node)),
                           substage, nil, nil, doctype(node))
        else
          IsoDoc::Iso::Metadata.new("en", "Latn", nil, @i18n)
            .status_abbrev(stage_abbr(stage, substage, doctype(node)),
                           substage, node.attr("iteration"),
                           node.attr("draft"), doctype(node))
        end
      end

      def cover_stage_abbr(node)
        stage = get_stage(node)
        abbr = id_stage_abbr(get_stage(node), get_substage(node), node, true)
        typeabbr = get_typeabbr(node, amd: true)
        if stage.to_i > 50 || (stage.to_i == 60 && get_substage(node).to_i < 60)
          typeabbr = ""
        end
        "#{abbr}#{typeabbr}".strip
      end

      def id_stage_prefix(docnum, node)
        stage = get_stage(node)
        typeabbr = get_typeabbr(node)
        if stage && (stage.to_i < 60)
          docnum = unpub_stage_prefix(docnum, stage, typeabbr, node)
        elsif typeabbr == "DIR " then docnum = "#{typeabbr}#{docnum}"
        elsif typeabbr && !@amd then docnum = "/#{typeabbr}#{docnum}"
        end
        docnum
      end

      def id_year(docnum, node, mode: :default)
        case mode
        when :strip then docnum.sub(/:(19|20)\d\d(?!\d)/, "")
        when :force then id_add_year(docnum, node)
        else
          stage = get_stage(node)
          if stage && (stage.to_i < 60)
            docnum
          else id_add_year(docnum, node)
          end
        end
      end

      def unpub_stage_prefix(docnum, stage, typeabbr, node)
        abbr = id_stage_abbr(stage, get_substage(node), node)
        %w(40 50).include?(stage) && i = node.attr("iteration") and
          itersuffix = ".#{i}"
        return docnum if abbr.nil? || abbr.empty? # prefixes added in cleanup

        typeabbr = "" if %w(DTS FDTS).include?(abbr.sub(/\s+$/, ""))
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
    end
  end
end
