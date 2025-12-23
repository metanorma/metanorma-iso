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

      def part_title(part, titlenums, lang)
        part or return ""
        suffix = to_xml(part.children)
        if titlenums[:part] &&
            t = title_part_prefix(titlenums[:part].document.root, "part", lang)
          i = IsoDoc::I18n.new(lang, ::Metanorma::Utils.default_script(lang))
          suffix = i.l10n("<esc>#{t}</esc>: <esc>#{suffix}</esc>")
        end
        suffix
      end

      def title_part_prefix(xml, part, lang)
        t = xml.at(ns("//bibdata/title[@language='#{lang}']"\
          "[@type='title-#{part}-prefix']")) or return
        to_xml(t.children)
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
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        set(:doctitlemain, tp[:main] ? to_xml(tp[:main].children) : "")
        tp[:intro] and set(:doctitleintro, to_xml(tp[:intro].children))
        tp[:complementary] and
          set(:doctitlecomplementary, to_xml(tp[:complementary].children))
        set(:doctitlepartlabel, title_part_prefix(isoxml, "part", lang))
        tp[:part] and set(:doctitlepart, to_xml(tp[:part].children))
        tn[:amd] and
          set(:doctitleamdlabel, title_part_prefix(isoxml, "amendment", lang))
        tp[:amd] and set(:doctitleamd, to_xml(tp[:amd].children))
        tn[:corr] and set(:doctitlecorrlabel,
                          title_part_prefix(isoxml, "corrigendum", lang))
        tn[:add] and set(:doctitleaddlabel,
                         title_part_prefix(isoxml, "addendum", lang))
        tp[:add] and set(:doctitleadd, to_xml(tp[:add].children))
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
      end

      def subtitle(isoxml, _out)
        lang = @lang == "en" ? "fr" : "en"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:docsubtitlemain, tp[:main] ? to_xml(tp[:main].children) : "")
        tp[:intro] and set(:docsubtitleintro, to_xml(tp[:intro].children))
        tp[:complementary] and
          set(:docsubtitlecomplementary, to_xml(tp[:complementary].children))
        set(:docsubtitlepartlabel, title_part_prefix(isoxml, "part", lang))
        tp[:part] and set(:docsubtitlepart, to_xml(tp[:part].children))
        tn[:amd] and set(:docsubtitleamdlabel,
                         title_part_prefix(isoxml, "amendment", lang))
        tp[:amd] and set(:docsubtitleamd, to_xml(tp[:amd].children))
        tn[:add] and set(:docsubtitleaddlabel,
                         title_part_prefix(isoxml, "addendum", lang))
        tp[:add] and set(:docsubtitleadd, to_xml(tp[:add].children))
        tn[:corr] and set(:docsubtitlecorrlabel,
                          title_part_prefix(isoxml, "corrigendum", lang))
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
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

      COMMITTEE = "//bibdata/contributor[role/@type = 'author'] " \
        "[role/description = 'committee']/organization".freeze

      def tc_base(xml, _grouptype)
        s = xml.at(ns("#{COMMITTEE}/subdivision[@type = 'Technical committee']"))
        s or return nil
        s.at(ns("./identifier[not(@type = 'full')]"))&.text
      end

      def sc(xml)
        scid = sc_base(xml, "editorialgroup") or return
        set(:sc, scid)
      end

      def sc_base(xml, _grouptype)
        s = xml.at(ns("#{COMMITTEE}/subdivision[@type = 'Subcommittee']"))
        s or return nil
        s.at(ns("./identifier[not(@type = 'full')]"))&.text
      end

      def wg(xml)
        wgid = wg_base(xml, "editorialgroup") or return
        set(:wg, wgid)
      end

      def wg_base(xml, _grouptype)
        s = xml.at(ns("#{COMMITTEE}/subdivision[@type = 'Workgroup']"))
        s or return nil
        s.at(ns("./identifier[not(@type = 'full')]"))&.text
      end

      def editorialgroup(xml)
        xpath = "#{COMMITTEE}/subdivision/identifier[@type = 'full']"
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
        sec = xml.at(ns("//bibdata/contributor[role/@type = 'author']" \
          "[role/description = 'secretariat']/organization/subdivision" \
          "[@type = 'Secretariat']/name"))
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
