require "isodoc"

module IsoDoc
  module Iso
    class  Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        @metadata = {
        tc: "XXXX",
        sc: "XXXX",
        wg: "XXXX",
        editorialgroup: [],
        secretariat: "XXXX",
        obsoletes: nil,
        obsoletes_part: nil
      }
      end

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

      def stage_abbrev(stage, iter, draft)
        return "" unless stage
        stage = STAGE_ABBRS[stage.to_sym] || "??"
        stage += iter if iter
        stage = "Pre" + stage if draft =~ /^0\./
        stage
      end

      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        set(:unpublished, false)
        if docstatus
          set(:stage, docstatus.text)
          set(:stage_int, docstatus.text.to_i)
          set(:unpublished, docstatus.text.to_i > 0 && docstatus.text.to_i < 60)
          abbr = stage_abbrev(docstatus.text, isoxml&.at(ns("//bibdata/status/iteration"))&.text,
                              isoxml&.at(ns("//version/draft"))&.text)
          set(:stageabbr, abbr)
        end
        revdate = isoxml.at(ns("//version/revision-date"))
        set(:revdate, revdate&.text)
      end

      def docid(isoxml, _out)
        dn = isoxml.at(ns("//bibdata/docidentifier[@type = 'iso']"))
        set(:docnumber, dn&.text)
        tcdn = isoxml.at(ns("//bibdata/docidentifier[@type = 'iso-tc']"))
        set(:tc_docnumber, tcdn&.text)
      end

      # we don't leave this to i18n.rb, because we have both English and
      # French titles in the same document
      def part_label(lang)
        case lang
        when "en" then "Part"
        when "fr" then "Partie"
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

      def title(isoxml, _out)
        intro = isoxml.at(ns("//bibdata//title[@type='title-intro' and @language='en']"))
        main = isoxml.at(ns("//bibdata//title[@type='title-main' and @language='en']"))
        part = isoxml.at(ns("//bibdata//title[@type='title-part' and @language='en']"))
        partnumber = isoxml.at(ns("//bibdata//project-number/@part"))
        subpartnumber = isoxml.at(ns("//bibdata//project-number/@subpart"))

        set(:doctitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, "en")
        set(:doctitle, main)
        set(:doctitleintro, @c.encode(intro ? intro.text : "", :hexadecimal)) if intro
        set(:doctitlepartlabel, part_prefix(partnumber, subpartnumber, "en"))
        set(:doctitlepart, @c.encode(part.text, :hexadecimal)) if part
      end

      def subtitle(isoxml, _out)
        intro = isoxml.at(ns("//bibdata//title[@type='title-intro' and @language='fr']"))
        main = isoxml.at(ns("//bibdata//title[@type='title-main' and @language='fr']"))
        part = isoxml.at(ns("//bibdata//title[@type='title-part' and @language='fr']"))
        partnumber = isoxml.at(ns("//bibdata//project-number/@part"))
        subpartnumber = isoxml.at(ns("//bibdata//project-number/@subpart"))
        set(:docsubtitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, "fr")
        set(:docsubtitle, main)
        set(:docsubtitleintro, @c.encode(intro ? intro.text : "", :hexadecimal)) if intro
        set(:docsubtitlepartlabel, part_prefix(partnumber, subpartnumber, "fr"))
        set(:docsubtitlepart, @c.encode(part.text, :hexadecimal)) if part
      end

      def author(xml, _out)
        super
        tc(xml)
        sc(xml)
        wg(xml)
        secretariat(xml)
      end

      def tc(xml)
        tc_num = xml.at(ns("//bibdata/ext/editorialgroup/technical-committee/@number"))
        tc_type = xml.at(ns("//bibdata/ext/editorialgroup/technical-committee/@type"))&.
          text || "TC"
        if tc_num
          tcid = "#{tc_type} #{tc_num.text}"
          set(:tc,  tcid)
          set(:editorialgroup, get[:editorialgroup] << tcid)
        end
      end

      def sc(xml)
        sc_num = xml.at(ns("//bibdata/ext/editorialgroup/subcommittee/@number"))
        sc_type = xml.at(ns("//bibdata/ext/editorialgroup/subcommittee/@type"))&.text || "SC"
        if sc_num
          scid = "#{sc_type} #{sc_num.text}"
          set(:sc, scid)
          set(:editorialgroup, get[:editorialgroup] << scid)
        end
      end

      def wg(xml)
        wg_num = xml.at(ns("//bibdata/ext/editorialgroup/workgroup/@number"))
        wg_type = xml.at(ns("//bibdata/ext/editorialgroup/workgroup/@type"))&.text || "WG"
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
        set(:ics, ics.empty? ? "XXX" : ics.join(", "))
      end
    end
  end
end
