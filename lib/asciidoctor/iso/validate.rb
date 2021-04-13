require "metanorma-standoc"
require_relative "./validate_style.rb"
require_relative "./validate_requirements.rb"
require_relative "./validate_section.rb"
require_relative "./validate_title.rb"
require "nokogiri"
require "jing"
require "iev"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      # ISO/IEC DIR 2, 22.3.2
      def onlychild_clause_validate(root)
        root.xpath(Standoc::Utils::SUBCLAUSE_XPATH).each do |c|
          next unless c.xpath("../clause").size == 1
          title = c.at("./title")
          location = c["id"] || c.text[0..60] + "..."
          location += ":#{title.text}" if c["id"] && !title.nil?
          @log.add("Style", nil, "#{location}: subclause is only child")
        end
      end

      def isosubgroup_validate(root)
        root.xpath("//technical-committee/@type").each do |t|
          unless %w{TC PC JTC JPC}.include? t.text
            @log.add("Document Attributes", nil,
                     "invalid technical committee type #{t}")
          end
        end
        root.xpath("//subcommittee/@type").each do |t|
          unless %w{SC JSC}.include? t.text
            @log.add("Document Attributes", nil,
                     "invalid subcommittee type #{t}")
          end
        end
      end

      # ISO/IEC DIR 2, 15.5.3
      def see_xrefs_validate(root)
        root.xpath("//xref").each do |t|
          # does not deal with preceding text marked up
          preceding = t.at("./preceding-sibling::text()[last()]")
          next unless !preceding.nil? &&
            /\b(see| refer to)\s*$/mi.match(preceding)

          (target = root.at("//*[@id = '#{t['target']}']")) || next
          if target&.at("./ancestor-or-self::*[@obligation = 'normative']")
            @log.add("Style", t,
                     "'see #{t['target']}' is pointing to a normative section")
          end
        end
      end

      # ISO/IEC DIR 2, 15.5.3
      def see_erefs_validate(root)
        root.xpath("//eref").each do |t|
          preceding = t.at("./preceding-sibling::text()[last()]")
          next unless !preceding.nil? &&
            /\b(see|refer to)\s*$/mi.match(preceding)

          unless target = root.at("//*[@id = '#{t['bibitemid']}']")
            @log.add("Bibliography", t,
                     "'#{t} is not pointing to a real reference")
            next
          end
          if target.at("./ancestor::references[@normative = 'true']")
            @log.add("Style", t,
                     "'see #{t}' is pointing to a normative reference")
          end
        end
      end

      # ISO/IEC DIR 2, 10.4
      def locality_erefs_validate(root)
        root.xpath("//eref[descendant::locality]").each do |t|
          if /^(ISO|IEC)/.match? t["citeas"]
            unless /:[ ]?(\d+{4}|–)$/.match t["citeas"]
              @log.add("Style", t,
                       "undated reference #{t['citeas']} should not contain "\
                       "specific elements")
            end
          end
        end
      end

      def termdef_warn(text, re, t, term, msg)
        re.match(text) && @log.add("Style", t, "#{term}: #{msg}")
      end

      # ISO/IEC DIR 2, 16.5.6
      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition") || return
          term = t.at("./preferred").text
          termdef_warn(para.text, /^(the|a)\b/i, t, term,
                       "term definition starts with article")
          termdef_warn(para.text, /\.$/i, t, term,
                       "term definition ends with period")
        end
        cited_term_style(xmldoc)
      end

      # ISO/IEC DIR 2, 16.5.10
      def cited_term_style(xmldoc)
        xmldoc.xpath("//term//xref").each do |x|
          next unless xmldoc.at("//term[@id = '#{x['target']}']")

          x&.previous&.text == " (" and x&.previous&.previous&.name == "em" or
            style_warning(x, "term citation not preceded with italicised term",
                          x.parent.text)
        end
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(international-standard technical-specification technical-report 
        publicly-available-specification international-workshop-agreement 
        guide amendment technical-corrigendum).include? doctype or
        @log.add("Document Attributes", nil,
                 "#{doctype} is not a recognised document type")
      end

      def script_validate(xmldoc)
        script = xmldoc&.at("//bibdata/script")&.text
        script == "Latn" or
          @log.add("Document Attributes", nil,
                   "#{script} is not a recognised script")
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(00 10 20 30 40 50 60 90 95).include? stage or
          @log.add("Document Attributes", nil,
                   "#{stage} is not a recognised stage")
      end

      def substage_validate(xmldoc)
        substage = xmldoc&.at("//bibdata/status/substage")&.text or return
        %w(00 20 60 90 92 93 98 99).include? substage or
          @log.add("Document Attributes", nil,
                   "#{substage} is not a recognised substage")
      end

      def iteration_validate(xmldoc)
        iteration = xmldoc&.at("//bibdata/status/iteration")&.text or return
        /^\d+/.match(iteration) or
          @log.add("Document Attributes", nil,
                   "#{iteration} is not a recognised iteration")
      end

      # DRG directives 3.7; but anticipated by standoc
      def subfigure_validate(xmldoc)
        xmldoc.xpath("//figure//figure").each do |f|
          { footnote: "fn", note: "note", key: "dl" }.each do |k, v|
            f.xpath(".//#{v}").each do |n|
              @log.add("Style", n, "#{k} is not permitted in a subfigure")
            end
          end
        end
      end

      def image_name_prefix(xmldoc)
        std = xmldoc&.at("//bibdata/ext/structuredidentifier/project-number") or
          return
        num = xmldoc&.at("//bibdata/docnumber")&.text or return
        ed = xmldoc&.at("//bibdata/edition")&.text || "1"
        prefix = num
        std["part"] and prefix += "-#{std['part']}"
        prefix += "_ed#{ed}"
        amd = std["amendment"] and prefix += "amd#{amd}"
        prefix
      end

      def image_name_suffix(xmldoc)
        case xmldoc&.at("//bibdata/language")&.text
        when "fr" then "_f"
        when "de" then "_d"
        when "ru" then "_r"
        when "es" then "_s"
        when "ar" then "_a"
        when "en" then "_e"
        else
          "_e"
        end
      end

      def disjunct_error(i, cond1, cond2, msg1, msg2)
        cond1 && !cond2 and
          @log.add("Style", i, "image name #{i['src']} #{msg1}")
        !cond1 && cond2 and
          @log.add("Style", i, "image name #{i['src']} #{msg2}")
      end

      def image_name_validate1(i, prefix)
        m = %r[(SL)?#{prefix}fig(?<tab>Tab)?(?<annex>[A-Z])?(Text)?(?<num>\d+)
            (?<subfig>[a-z])?(?<key>_key\d+)?(?<lang>_[a-z])?$]x.match(File.basename(i["src"], ".*"))
        if m.nil?
          @log.add("Style", i, "image name #{i['src']} does not match DRG requirements")
          return
        end
        warn i["src"]
        disjunct_error(i, i.at("./ancestor::table"), !m[:tab].nil?,
                       "is under a table but is not so labelled",
                       "is labelled as under a table but is not")
        disjunct_error(i, i.at("./ancestor::annex"), !m[:annex].nil?,
                       "is under an annex but is not so labelled",
                       "is labelled as under an annex but is not")
        disjunct_error(i, i.xpath("./ancestor::figure").size > 1, !m[:subfig].nil?,
                       "does not have a subfigure letter but is a subfigure",
                       "has a subfigure letter but is not a subfigure")
        lang = image_name_suffix(i.document.root)
        (m[:lang] || "_e") == lang or
          @log.add("Style", i, "image name #{i['src']} expected to have suffix #{lang}")
      end

      # DRG directives 3.2
      def image_name_validate(xmldoc)
        prefix = image_name_prefix(xmldoc) or return
        xmldoc.xpath("//image").each do |i|
          next if i["src"].start_with?("data:")

          if /^ISO_\d+_/.match?(File.basename(i["src"]))
          elsif /^(SL)?#{prefix}fig/.match?(File.basename(i["src"]))
            image_name_validate1(i, prefix)
          else
            @log.add("Style", i,
                     "image name #{i['src']} does not match DRG requirements: expect #{prefix}fig")
          end
        end
      end

      def figure_validate(xmldoc)
        image_name_validate(xmldoc)
        subfigure_validate(xmldoc)
      end

      def bibdata_validate(doc)
        doctype_validate(doc)
        script_validate(doc)
        stage_validate(doc)
        substage_validate(doc)
        iteration_validate(doc)
      end

      def content_validate(doc)
        super
        title_validate(doc.root)
        isosubgroup_validate(doc.root)
        onlychild_clause_validate(doc.root)
        termdef_style(doc.root)
        iev_validate(doc.root)
        see_xrefs_validate(doc.root)
        see_erefs_validate(doc.root)
        locality_erefs_validate(doc.root)
        bibdata_validate(doc.root)
        bibitem_validate(doc.root)
        figure_validate(doc.root)
      end

      def bibitem_validate(xmldoc)
        xmldoc.xpath("//bibitem[date/on = '–']").each do |b|
          b.at("./note[@type = 'Unpublished-Status']") or
            @log.add("Style", b,
                     "Reference #{b&.at('./@id')&.text} does not have an "\
                     "associated footnote indicating unpublished status")
        end
      end

      def validate(doc)
        content_validate(doc)
        doctype = doc&.at("//bibdata/ext/doctype")&.text
        schema = case doctype
                 when "amendment", "technical-corrigendum" # @amd
                   "isostandard-amd.rng"
                 else
                   "isostandard.rng"
                 end
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), schema))
      end
    end
  end
end
