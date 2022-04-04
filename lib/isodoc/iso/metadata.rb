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
        set(:docnumber, isoxml&.at(ns("//bibdata/docidentifier[@type = 'ISO']"))&.text)
        set(:tc_docnumber, isoxml.xpath(ns("//bibdata/docidentifier[@type = 'iso-tc']")).map(&:text))
        set(:docnumber_lang, isoxml&.at(ns("//bibdata/docidentifier[@type = 'iso-with-lang']"))&.text)
        set(:docnumber_reference, isoxml&.at(ns("//bibdata/docidentifier[@type = 'iso-reference']"))&.text)
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

      def part_title(part, partnum, subpartnum, lang)
        return "" unless part

        suffix = @c.encode(part.text, :hexadecimal)
        partnum = "#{partnum}&ndash;#{subpartnum}" if partnum && subpartnum
        suffix = "#{part_label(lang)}&nbsp;#{partnum}: " + suffix if partnum
        suffix
      end

      def part_prefix(partnum, subpartnum, lang)
        partnum = "#{partnum}&ndash;#{subpartnum}" if partnum && subpartnum
        "#{part_label(lang)}&nbsp;#{partnum}"
      end

      def amd_prefix(num, lang)
        "#{amd_label(lang)}&nbsp;#{num}"
      end

      def corr_prefix(num, lang)
        "#{corr_label(lang)}&nbsp;#{num}"
      end

      def compose_title(main, intro, part, partnum, subpartnum, lang)
        main = main.nil? ? "" : @c.encode(main.text, :hexadecimal)
        intro &&
          main = "#{@c.encode(intro.text, :hexadecimal)}&nbsp;&mdash; #{main}"
        if part
          suffix = part_title(part, partnum, subpartnum, lang)
          main = "#{main}&nbsp;&mdash; #{suffix}"
        end
        main
      end

      def title_nums(isoxml)
        [isoxml.at(ns("//bibdata//project-number/@part")),
         isoxml.at(ns("//bibdata//project-number/@subpart")),
         isoxml.at(ns("//bibdata//project-number/@amendment")),
         isoxml.at(ns("//bibdata//project-number/@corrigendum"))]
      end

      def title_parts(isoxml, lang)
        [isoxml.at(ns("//bibdata//title[@type='title-intro' and "\
                      "@language='#{lang}']")),
         isoxml.at(ns("//bibdata//title[@type='title-main' and "\
                      "@language='#{lang}']")),
         isoxml.at(ns("//bibdata//title[@type='title-part' and "\
                      "@language='#{lang}']")),
         isoxml.at(ns("//bibdata//title[@type='title-amd' and "\
                      "@language='#{lang}']"))]
      end

      def title(isoxml, _out)
        lang = case @lang
               when "fr" then "fr"
               when "ru" then "ru"
               else "en"
               end
        intro, main, part, amd = title_parts(isoxml, lang)
        partnumber, subpartnumber, amdnumber, corrnumber = title_nums(isoxml)

        set(:doctitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, lang)
        set(:doctitle, main)
        if intro
          set(:doctitleintro,
              @c.encode(intro ? intro.text : "", :hexadecimal))
        end
        set(:doctitlepartlabel, part_prefix(partnumber, subpartnumber, lang))
        set(:doctitlepart, @c.encode(part.text, :hexadecimal)) if part
        set(:doctitleamdlabel, amd_prefix(amdnumber, lang)) if amdnumber
        set(:doctitleamd, @c.encode(amd.text, :hexadecimal)) if amd
        set(:doctitlecorrlabel, corr_prefix(corrnumber, lang)) if corrnumber
      end

      def subtitle(isoxml, _out)
        lang = @lang == "en" ? "fr" : "en"
        intro, main, part, amd = title_parts(isoxml, lang)
        partnumber, subpartnumber, amdnumber, corrnumber = title_nums(isoxml)

        set(:docsubtitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, lang)
        set(:docsubtitle, main)
        if intro
          set(:docsubtitleintro,
              @c.encode(intro ? intro.text : "", :hexadecimal))
        end
        set(:docsubtitlepartlabel, part_prefix(partnumber, subpartnumber, lang))
        set(:docsubtitlepart, @c.encode(part.text, :hexadecimal)) if part
        set(:docsubtitleamdlabel, amd_prefix(amdnumber, lang)) if amdnumber
        set(:docsubtitleamd, @c.encode(amd.text, :hexadecimal)) if amd
        set(:docsubtitlecorrlabel, corr_prefix(corrnumber, lang)) if corrnumber
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
        a = isoxml.at(ns("//bibdata/ext/horizontal")) and set(:horizontal,
                                                              a.text)
      end
    end
  end
end
