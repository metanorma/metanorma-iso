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
        stage or return ""
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
        published = published_default(isoxml)
        revdate = isoxml.at(ns("//bibdata/version/revision-date"))
        set(:revdate, revdate&.text)
        docstatus and docstatus1(isoxml, docstatus, published)
        docscheme = isoxml.at(ns("//presentation-metadata[name" \
          "[text() = 'document-scheme']]/value"))
        docscheme and set(:document_scheme, docscheme.text)
      end

      def docstatus1(isoxml, docstatus, published)
        set(:stage, docstatus.text)
        set(:stage_int, docstatus.text.to_i)
        set(:substage_int, isoxml.at(ns("//bibdata/status/substage"))&.text)
        set(:statusabbr,
            status_abbrev(docstatus["abbreviation"] || "??",
                          isoxml.at(ns("//bibdata/status/substage"))&.text,
                          isoxml.at(ns("//bibdata/status/iteration"))&.text,
                          isoxml.at(ns("//bibdata/version/draft"))&.text,
                          isoxml.at(ns("//bibdata/ext/doctype"))&.text))
        !published and set(:stageabbr, docstatus["abbreviation"])
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
      ADD_LABEL = { en: "ADDENDUM", fr: "ADDITIF", ru: "ДОПОЛНЕНИЕ" }.freeze
      CORR_LABEL = { en: "TECHNICAL CORRIGENDUM",
                     fr: "RECTIFICATIF TECHNIQUE",
                     ru: "ТЕХНИЧЕСКОЕ ИСПРАВЛЕНИЕ" }.freeze

      def part_title(part, titlenums, lang)
        part or return ""
        suffix = to_xml(part.children)
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

      def add_prefix(titlenums, lang)
        "#{self.class::ADD_LABEL[lang.to_sym]}&#xa0;#{titlenums[:add]}"
      end

      def corr_prefix(titlenums, lang)
        "#{self.class::CORR_LABEL[lang.to_sym]}&#xa0;#{titlenums[:corr]}"
      end

      def compose_title(tparts, tnums, lang)
        t = tparts[:main].nil? ? "" :  to_xml(tparts[:main].children)
        tparts[:intro] and
          t = "#{to_xml(tparts[:intro].children)}&#xa0;&#x2014; #{t}"
        tparts[:complementary] and
          t = "#{t}&#xa0;&#x2014; #{to_xml(tparts[:complementary].children)}"
        if tparts[:part]
          suffix = part_title(tparts[:part], tnums, lang)
          t = "#{t}&#xa0;&#x2014; #{suffix}"
        end
        t
      end

      def title_nums(isoxml)
        prefix = "//bibdata/ext/structuredidentifier/project-number"
        { part: isoxml.at(ns("#{prefix}/@part")),
          subpart: isoxml.at(ns("#{prefix}/@subpart")),
          amd: isoxml.at(ns("#{prefix}/@amendment")),
          add: isoxml.at(ns("#{prefix}/@addendum")),
          corr: isoxml.at(ns("#{prefix}/@corrigendum")) }
      end

      def title_parts(isoxml, lang)
        %w(intro main complementary part amd add).each_with_object({}) do |w, m|
          m[w.to_sym] = isoxml.at(ns("//bibdata/title[@type='title-#{w}' and " \
                              "@language='#{lang}']"))
        end
      end

      def title(isoxml, _out)
        lang = case @lang
               when "fr", "ru" then @lang
               else "en"
               end
        # intro, main, complementary, part, amd = title_parts(isoxml, lang)
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        set(:doctitlemain, tp[:main] ? to_xml(tp[:main].children) : "")
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        tp[:intro] and set(:doctitleintro, to_xml(tp[:intro].children))
        tp[:complementary] and
          set(:doctitlecomplementary, to_xml(tp[:complementary].children))
        set(:doctitlepartlabel, part_prefix(tn, lang))
        set(:doctitlepart, to_xml(tp[:part].children)) if tp[:part]
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:doctitleamd, to_xml(tp[:amd].children)) if tp[:amd]
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
        set(:doctitleaddlabel, add_prefix(tn, lang)) if tn[:add]
        set(:doctitleadd, to_xml(tp[:add].children)) if tp[:add]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "en" ? "fr" : "en"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:docsubtitlemain, tp[:main] ? to_xml(tp[:main].children) : "")
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        tp[:intro] and set(:docsubtitleintro, to_xml(tp[:intro].children))
        tp[:complementary] and
          set(:docsubtitlecomplementary, to_xml(tp[:complementary].children))
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        tp[:part] and set(:docsubtitlepart, to_xml(tp[:part].children))
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:docsubtitleamd, to_xml(tp[:amd].children)) if tp[:amd]
        set(:docsubtitleaddlabel, add_prefix(tn, lang)) if tn[:add]
        set(:docsubtitleadd, to_xml(tp[:add].children)) if tp[:add]
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
        xpath = <<~XPATH
          //contributor[role/@type = 'author'][role/description = 'Technical committee']/organization/subdivision/identifier[@type = 'full']
        XPATH
        a = xml.xpath(ns(xpath))
        a.empty? or set(:editorialgroup,
                        connectives_strip(@i18n.boolean_conj(a.map(&:text),
                                                             "and")))
        a = xml.xpath(ns(xpath.sub("author", "authorizer")))
        a.empty? or set(:approvalgroup,
                        connectives_strip(@i18n.boolean_conj(a.map(&:text),
                                                             "and")))
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
