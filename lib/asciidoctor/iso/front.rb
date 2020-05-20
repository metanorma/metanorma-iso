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

      def stage_abbr(stage, substage)
        return nil if stage.to_i > 60
        return "PRF" if stage == "60" && substage == "00"
        STAGE_ABBRS[stage.to_sym]
      end

      def stage_name(stage, substage)
        return "Proof" if stage == "60" && substage == "00"
        STAGE_NAMES[stage.to_sym]
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
          return add_id_parts(node.attr("docnumber"), part, subpart)
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

      def metadata_ext(node, xml)
        super
        structured_id(node, xml)
        xml.stagename stage_name(get_stage(node), get_substage(node))
        @amd && a = node.attr("updates-document-type") and
          xml.updates_document_type a
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
          status_abbrev(stage_abbr(stage, substage), substage, node.attr("iteration"),
                        node.attr("draft"))
      end

      def id_stage_prefix(dn, node, force_year)
        stage = get_stage(node)
        substage = get_substage(node)
        if stage && (stage.to_i < 60)
          abbr = id_stage_abbr(stage, substage, node)
          unless abbr.nil? || abbr.empty? # prefixes added in cleanup
            dn = @amd ? dn.sub(/ /, "/#{abbr} ") : "/#{abbr} #{dn}"
          end
        end
        if force_year || !(stage && (stage.to_i < 60))
          year = @amd ? (node.attr("copyright-year") || node.attr("updated-date").sub(/-.*$/, "")) :
            node.attr("copyright-year")
          dn += ":#{year}" if year
        end
        dn
      end

      def organization(org, orgname)
        if ["ISO",
            "International Organization for Standardization"].include? orgname
          org.name "International Organization for Standardization"
          org.abbreviation "ISO"
        elsif ["IEC",
               "International Electrotechnical Commission"].include? orgname
          org.name "International Electrotechnical Commission"
          org.abbreviation "IEC"
        else
          org.name orgname
        end
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "ISO"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
      end

      def get_substage(node)
        stage = get_stage(node)
        node.attr("docsubstage") || ( stage == "60" ? "60" : "00" )
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        xml.status do |s|
          s.stage stage, **attr_code(abbreviation: stage_abbr(stage, substage))
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
        return unless node.attr("title-amd-#{lang}")
        t.title(**attr_code(at.merge(type: "title-amd"))) do |t1|
          t1 << Asciidoctor::Standoc::Utils::asciidoc_sub(node.attr("title-amd-#{lang}"))
        end
      end

      def title_full(node, t, lang, at)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}")
        amd = node.attr("title-amd-#{lang}")
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
