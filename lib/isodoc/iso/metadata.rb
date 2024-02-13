require "isodoc"

module IsoDoc
  module Iso
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, locale, i18n)
        super
        DATETYPES.each { |w| @metadata["#{w.gsub(/-/, '_')}date".to_sym] = nil }
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
        part or return ""
        suffix = part.children.to_xml
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
        "#{self.class::PART_LABEL[lang.to_sym]}&#xa0;#{p}"
      end

      def amd_prefix(titlenums, lang)
        "#{self.class::AMD_LABEL[lang.to_sym]}&#xa0;#{titlenums[:amd]}"
      end

      def corr_prefix(titlenums, lang)
        "#{self.class::CORR_LABEL[lang.to_sym]}&#xa0;#{titlenums[:corr]}"
      end

      def compose_title(tparts, tnums, lang)
        main = ""
        tparts[:main].nil? or
          main = tparts[:main].children.to_xml
        tparts[:intro] and
          main = "#{tparts[:intro].children.to_xml}&#xa0;&#x2014; #{main}"
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
        { intro: isoxml.at(ns("//bibdata/title[@type='title-intro' and " \
                              "@language='#{lang}']")),
          main: isoxml.at(ns("//bibdata/title[@type='title-main' and " \
                             "@language='#{lang}']")),
          part: isoxml.at(ns("//bibdata/title[@type='title-part' and " \
                             "@language='#{lang}']")),
          amd: isoxml.at(ns("//bibdata/title[@type='title-amd' and " \
                            "@language='#{lang}']")) }
      end

      def title(isoxml, _out)
        lang = case @lang
               when "fr", "ru" then @lang
               else "en"
               end
        # intro, main, part, amd = title_parts(isoxml, lang)
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        set(:doctitlemain, tp[:main] ? tp[:main].children.to_xml : "")
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        tp[:intro] and set(:doctitleintro, tp[:intro].children.to_xml)
        set(:doctitlepartlabel, part_prefix(tn, lang))
        set(:doctitlepart, tp[:part].children.to_xml) if tp[:part]
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:doctitleamd, tp[:amd].children.to_xml) if tp[:amd]
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "en" ? "fr" : "en"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:docsubtitlemain, tp[:main] ? tp[:main].children.to_xml : "")
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        tp[:intro] and set(:docsubtitleintro, tp[:intro].children.to_xml)
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        tp[:part] and set(:docsubtitlepart, tp[:part].children.to_xml)
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:docsubtitleamd, tp[:amd].children.to_xml) if tp[:amd]
        set(:docsubtitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def author(xml, _out)
        super
        tc(xml)
        sc(xml)
        wg(xml)
        editorialgroup(xml)
        secretariat(xml)
      end

      def tc(xml)
        tcid = tc_base(xml, "editorialgroup") or return
        set(:tc, tcid)
      end

      def tc_base(xml, grouptype)
        tc_num = xml.at(ns("//bibdata/ext/#{grouptype}/" \
                           "technical-committee/@number")) or return nil
        tc_type = xml.at(ns("//bibdata/ext/#{grouptype}/technical-committee/" \
                            "@type"))&.text || "TC"
        tc_type == "Other" and tc_type = ""
        "#{tc_type} #{tc_num.text}".strip
      end

      def sc(xml)
        scid = sc_base(xml, "editorialgroup") or return
        set(:sc, scid)
      end

      def sc_base(xml, grouptype)
        sc_num = xml.at(ns("//bibdata/ext/#{grouptype}/subcommittee/" \
                           "@number")) or return nil
        sc_type = xml.at(ns("//bibdata/ext/#{grouptype}/subcommittee/" \
                            "@type"))&.text || "SC"
        sc_type == "Other" and sc_type = ""
        "#{sc_type} #{sc_num.text}"
      end

      def wg(xml)
        wgid = wg_base(xml, "editorialgroup") or return
        set(:wg, wgid)
      end

      def wg_base(xml, grouptype)
        wg_num = xml.at(ns("//bibdata/ext/#{grouptype}/workgroup/" \
                           "@number")) or return
        wg_type = xml.at(ns("//bibdata/ext/#{grouptype}/workgroup/" \
                            "@type"))&.text || "WG"
        wg_type == "Other" and wg_type = ""
        "#{wg_type} #{wg_num.text}"
      end

      def editorialgroup(xml)
        a = xml.at(ns("//bibdata/ext/editorialgroup/@identifier")) and
          set(:editorialgroup, a.text)
        a = xml.at(ns("//bibdata/ext/approvalgroup/@identifier")) and
          set(:approvalgroup, a.text)
      end

      def secretariat(xml)
        sec = xml.at(ns("//bibdata/ext/editorialgroup/secretariat"))
        set(:secretariat, sec.text) if sec
      end

      def doctype(isoxml, _out)
        super
        ics = isoxml.xpath(ns("//bibdata/ext/ics/code"))
          .each_with_object([]) { |i, m| m << i.text }
        set(:ics, ics.empty? ? nil : ics.join(", "))
        a = isoxml.at(ns("//bibdata/ext/horizontal")) and
          set(:horizontal, a.text)
        a = isoxml.at(ns("//bibdata/ext/fast-track")) and
          set(:fast_track, a.text)
      end
    end
  end
end
