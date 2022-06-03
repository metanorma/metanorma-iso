require "isodoc"

module IsoDoc
  module Iso
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, i18n)
        super
        DATETYPES.each { |w| @metadata["#{w.gsub(/-/, '_')}date".to_sym] = nil }
        set(:editorialgroup, [])
        set(:obsoletes, nil)
        set(:obsoletes_part, nil)
      end

      def status_abbrev(stage, _substage, iter, draft, doctype)
        return "" unless stage

        if %w(technical-report technical-specification).include?(doctype)
          stage = "DTS" if stage == "DIS"
          stage = "FDTS" if stage == "FDIS"
        end
        %w(PWI NWIP WD CD).include?(stage) && iter and stage += iter
        stage = "Pre#{stage}" if /^0\./.match?(draft)
        stage
      end

      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        set(:unpublished, false)
        revdate = isoxml.at(ns("//bibdata/version/revision-date"))
        set(:revdate, revdate&.text)
        docstatus and docstatus1(isoxml, docstatus)
      end

      def docstatus1(isoxml, docstatus)
        set(:stage, docstatus.text)
        set(:stage_int, docstatus.text.to_i)
        set(:substage_int, isoxml.at(ns("//bibdata/status/substage"))&.text)
        set(:unpublished, unpublished(docstatus.text))
        set(:statusabbr,
            status_abbrev(docstatus["abbreviation"] || "??",
                          isoxml.at(ns("//bibdata/status/substage"))&.text,
                          isoxml.at(ns("//bibdata/status/iteration"))&.text,
                          isoxml.at(ns("//bibdata/version/draft"))&.text,
                          isoxml.at(ns("//bibdata/ext/doctype"))&.text))
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
      PART_LABEL = { en: "Part", fr: "Partie", ru: "Часть" }.freeze
      AMD_LABEL = { en: "AMENDMENT", fr: "AMENDMENT", ru: "ПОПРАВКА" }.freeze
      CORR_LABEL = { en: "TECHNICAL CORRIGENDUM",
                     fr: "RECTIFICATIF TECHNIQUE",
                     ru: "ТЕХНИЧЕСКОЕ ИСПРАВЛЕНИЕ" }.freeze

      def part_title(part, titlenums, lang)
        return "" unless part

        suffix = @c.encode(part.text, :hexadecimal)
        p = titlenums[:part]
        titlenums[:part] && titlenums[:subpart] and
          p = "#{titlenums[:part]}&#x2013;#{titlenums[:subpart]}"
        titlenums[:part] and
          suffix = "#{PART_LABEL[lang.to_sym]}&#xa0;#{p}: " + suffix
        suffix
      end

      def part_prefix(titlenums, lang)
        p = titlenums[:part]
        titlenums[:part] && titlenums[:subpart] and
          p = "#{titlenums[:part]}&#x2013;#{titlenums[:subpart]}"
        "#{PART_LABEL[lang.to_sym]}&#xa0;#{p}"
      end

      def amd_prefix(titlenums, lang)
        "#{AMD_LABEL[lang.to_sym]}&#xa0;#{titlenums[:amd]}"
      end

      def corr_prefix(titlenums, lang)
        "#{CORR_LABEL[lang.to_sym]}&#xa0;#{titlenums[:corr]}"
      end

      def compose_title(tparts, tnums, lang)
        main = ""
        tparts[:main].nil? or
          main = @c.encode(tparts[:main].text, :hexadecimal)
        tparts[:intro] &&
          main = "#{@c.encode(tparts[:intro].text,
                              :hexadecimal)}&#xa0;&#x2014; #{main}"
        if tparts[:part]
          suffix = part_title(tparts[:part], tnums, lang)
          main = "#{main}&#xa0;&#x2014; #{suffix}"
        end
        main
      end

      def title_nums(isoxml)
        prefix = "//bibdata/ext/structuredidentifier/project-number"
        { part: isoxml.at(ns("#{prefix}/@part")),
          subpart: isoxml.at(ns("#{prefix}/@subpart")),
          amd: isoxml.at(ns("#{prefix}/@amendment")),
          corr: isoxml.at(ns("#{prefix}/@corrigendum")) }
      end

      def title_parts(isoxml, lang)
        { intro: isoxml.at(ns("//bibdata/title[@type='title-intro' and "\
                              "@language='#{lang}']")),
          main: isoxml.at(ns("//bibdata/title[@type='title-main' and "\
                             "@language='#{lang}']")),
          part: isoxml.at(ns("//bibdata/title[@type='title-part' and "\
                             "@language='#{lang}']")),
          amd: isoxml.at(ns("//bibdata/title[@type='title-amd' and "\
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
        tp[:intro] and
          set(:doctitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
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
        tp[:intro] and
          set(:docsubtitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        tp[:part] and
          set(:docsubtitlepart,
              @c.encode(tp[:part].text, :hexadecimal))
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:docsubtitleamd, @c.encode(tp[:amd].text, :hexadecimal)) if tp[:amd]
        set(:docsubtitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def author(xml, _out)
        super
        tc(xml)
        sc(xml)
        wg(xml)
        approvalgroup(xml)
        secretariat(xml)
      end

      def tc(xml)
        tcid = tc_base(xml, "editorialgroup") or return
        set(:tc, tcid)
        set(:editorialgroup, get[:editorialgroup] << tcid)
      end

      def tc_base(xml, grouptype)
        tc_num = xml.at(ns("//bibdata/ext/#{grouptype}/"\
                           "technical-committee/@number")) or return nil
        tc_type = xml.at(ns("//bibdata/ext/#{grouptype}/technical-committee/"\
                            "@type"))&.text || "TC"
        "#{tc_type} #{tc_num.text}"
      end

      def sc(xml)
        scid = sc_base(xml, "editorialgroup") or return
        set(:sc, scid)
        set(:editorialgroup, get[:editorialgroup] << scid)
      end

      def sc_base(xml, grouptype)
        sc_num = xml.at(ns("//bibdata/ext/#{grouptype}/subcommittee/"\
                           "@number")) or return nil
        sc_type = xml.at(ns("//bibdata/ext/#{grouptype}/subcommittee/"\
                            "@type"))&.text || "SC"
        "#{sc_type} #{sc_num.text}"
      end

      def wg(xml)
        wgid = wg_base(xml, "editorialgroup") or return
        set(:wg, wgid)
        set(:editorialgroup, get[:editorialgroup] << wgid)
      end

      def wg_base(xml, grouptype)
        wg_num = xml.at(ns("//bibdata/ext/#{grouptype}/workgroup/"\
                           "@number")) or return
        wg_type = xml.at(ns("//bibdata/ext/#{grouptype}/workgroup/"\
                            "@type"))&.text || "WG"
        "#{wg_type} #{wg_num.text}"
      end

      def approvalgroup(xml)
        ag = tc_base(xml, "approvalgroup") or return
        ret = [ag]
        ret << sc_base(xml, "approvalgroup")
        ret << wg_base(xml, "approvalgroup")
        set(:approvalgroup, ret)
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
