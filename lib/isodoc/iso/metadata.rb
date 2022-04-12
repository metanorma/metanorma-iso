require "isodoc"

module IsoDoc
  module Iso
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, i18n)
        super
        set(:tc, "XXXX")
        set(:sc, "XXXX")
        set(:wg, "XXXX")
        set(:editorialgroup, [])
        set(:secretariat, "XXX")
        set(:obsoletes, nil)
        set(:obsoletes_part, nil)
      end

      def status_abbrev(stage, _substage, iter, draft, doctype)
        return "" unless stage

        if %w(technical-report technical-specification).include?(doctype)
          stage = "DTS" if stage == "DIS"
          stage = "FDTS" if stage == "FDIS"
        end
        %w(PWI NWIP WD CD).include?(stage) && iter and
          stage += iter
        stage = "Pre#{stage}" if /^0\./.match?(draft)
        stage
      end

      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        set(:unpublished, false)
        revdate = isoxml.at(ns("//bibdata/version/revision-date"))
        set(:revdate, revdate&.text)
        if docstatus
          docstatus1(isoxml, docstatus)
        end
      end

      def docstatus1(isoxml, docstatus)
        set(:stage, docstatus.text)
        set(:stage_int, docstatus.text.to_i)
        set(:unpublished, unpublished(docstatus.text))
        set(:statusabbr,
            status_abbrev(docstatus["abbreviation"] || "??",
                          isoxml&.at(ns("//bibdata/status/substage"))&.text,
                          isoxml&.at(ns("//bibdata/status/iteration"))&.text,
                          isoxml&.at(ns("//bibdata/version/draft"))&.text,
                          isoxml&.at(ns("//bibdata/ext/doctype"))&.text))
        unpublished(docstatus.text) and
          set(:stageabbr, docstatus["abbreviation"])
      end

      def unpublished(status)
        status.to_i.positive? && status.to_i < 60
      end

      def docid(isoxml, _out)
        set(:tc_docnumber, isoxml
          .xpath(ns("//bibdata/docidentifier[@type = 'iso-tc']")).map(&:text))
        { docnumber: "ISO", docnumber_lang: "iso-with-lang",
          docnumber_reference: "iso-reference",
          docnumber_undated: "iso-undated" }.each do |k, v|
          set(k,
              isoxml&.at(ns("//bibdata/docidentifier[@type = '#{v}']"))&.text)
        end
      end

      # we don't leave this to i18n.rb, because we have both English and
      # French titles in the same document
      def part_label(lang)
        case lang
        when "en" then "Part"
        when "fr" then "Partie"
        when "ru" then "Часть"
        end
      end

      def amd_label(lang)
        case lang
        when "en", "fr" then "AMENDMENT"
        when "ru" then "ПОПРАВКА"
        end
      end

      def corr_label(lang)
        case lang
        when "en" then "TECHNICAL CORRIGENDUM"
        when "fr" then "RECTIFICATIF TECHNIQUE"
        when "ru" then "ТЕХНИЧЕСКОЕ ИСПРАВЛЕНИЕ"
        end
      end

      def part_title(part, titlenums, lang)
        return "" unless part

        suffix = @c.encode(part.text, :hexadecimal)
        p = titlenums[:part]
        titlenums[:part] && titlenums[:subpart] and
          p = "#{titlenums[:part]}&ndash;#{titlenums[:subpart]}"
        titlenums[:part] and
          suffix = "#{part_label(lang)}&nbsp;#{p}: " + suffix
        suffix
      end

      def part_prefix(titlenums, lang)
        p = titlenums[:part]
        titlenums[:part] && titlenums[:subpart] and
          p = "#{titlenums[:part]}&ndash;#{titlenums[:subpart]}"
        "#{part_label(lang)}&nbsp;#{p}"
      end

      def amd_prefix(titlenums, lang)
        "#{amd_label(lang)}&nbsp;#{titlenums[:amd]}"
      end

      def corr_prefix(titlenums, lang)
        "#{corr_label(lang)}&nbsp;#{titlenums[:corr]}"
      end

      def compose_title(tparts, tnums, lang)
        main = ""
        tparts[:main].nil? or
          main = @c.encode(tparts[:main].text, :hexadecimal)
        tparts[:intro] &&
          main = "#{@c.encode(tparts[:intro].text,
                              :hexadecimal)}&nbsp;&mdash; #{main}"
        if tparts[:part]
          suffix = part_title(tparts[:part], tnums, lang)
          main = "#{main}&nbsp;&mdash; #{suffix}"
        end
        main
      end

      def title_nums(isoxml)
        { part: isoxml.at(ns("//bibdata//project-number/@part")),
          subpart: isoxml.at(ns("//bibdata//project-number/@subpart")),
          amd: isoxml.at(ns("//bibdata//project-number/@amendment")),
          corr: isoxml.at(ns("//bibdata//project-number/@corrigendum")) }
      end

      def title_parts(isoxml, lang)
        { intro: isoxml.at(ns("//bibdata//title[@type='title-intro' and "\
                              "@language='#{lang}']")),
          main: isoxml.at(ns("//bibdata//title[@type='title-main' and "\
                             "@language='#{lang}']")),
          part: isoxml.at(ns("//bibdata//title[@type='title-part' and "\
                             "@language='#{lang}']")),
          amd: isoxml.at(ns("//bibdata//title[@type='title-amd' and "\
                            "@language='#{lang}']")) }
      end

      def title(isoxml, _out)
        lang = case @lang
               when "fr" then "fr"
               when "ru" then "ru"
               else "en"
               end
        # intro, main, part, amd = title_parts(isoxml, lang)
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:doctitlemain,
            @c.encode(tp[:main] ? tp[:main].text : "", :hexadecimal))
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        if tp[:intro]
          set(:doctitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
        end
        set(:doctitlepartlabel, part_prefix(tn, lang))
        set(:doctitlepart, @c.encode(tp[:part].text, :hexadecimal)) if tp[:part]
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:doctitleamd, @c.encode(tp[:amd].text, :hexadecimal)) if tp[:amd]
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "en" ? "fr" : "en"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:docsubtitlemain,
            @c.encode(tp[:main] ? tp[:main].text : "", :hexadecimal))
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        if tp[:intro]
          set(:docsubtitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
        end
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        if tp[:part]
          set(:docsubtitlepart,
              @c.encode(tp[:part].text, :hexadecimal))
        end
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:docsubtitleamd, @c.encode(tp[:amd].text, :hexadecimal)) if tp[:amd]
        set(:docsubtitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def author(xml, _out)
        super
        tc(xml)
        sc(xml)
        wg(xml)
        secretariat(xml)
      end

      def tc(xml)
        tc_type = xml.at(ns("//bibdata/ext/editorialgroup/technical-committee/"\
                            "@type"))&.text || "TC"
        if tc_num = xml.at(ns("//bibdata/ext/editorialgroup/"\
                              "technical-committee/@number"))
          tcid = "#{tc_type} #{tc_num.text}"
          set(:tc,  tcid)
          set(:editorialgroup, get[:editorialgroup] << tcid)
        end
      end

      def sc(xml)
        sc_num = xml.at(ns("//bibdata/ext/editorialgroup/subcommittee/@number"))
        sc_type = xml.at(ns("//bibdata/ext/editorialgroup/subcommittee/"\
                            "@type"))&.text || "SC"
        if sc_num
          scid = "#{sc_type} #{sc_num.text}"
          set(:sc, scid)
          set(:editorialgroup, get[:editorialgroup] << scid)
        end
      end

      def wg(xml)
        wg_num = xml.at(ns("//bibdata/ext/editorialgroup/workgroup/@number"))
        wg_type = xml.at(ns("//bibdata/ext/editorialgroup/workgroup/"\
                            "@type"))&.text || "WG"
        if wg_num
          wgid = "#{wg_type} #{wg_num.text}"
          set(:wg, wgid)
          set(:editorialgroup, get[:editorialgroup] << wgid)
        end
      end

      def secretariat(xml)
        sec = xml.at(ns("//bibdata/ext/editorialgroup/secretariat"))
        set(:secretariat, sec.text) if sec
      end

      def doctype(isoxml, _out)
        super
        ics = []
        isoxml.xpath(ns("//bibdata/ext/ics/code")).each { |i| ics << i.text }
        set(:ics, ics.empty? ? nil : ics.join(", "))
        a = isoxml.at(ns("//bibdata/ext/horizontal")) and
          set(:horizontal, a.text)
      end
    end
  end
end
