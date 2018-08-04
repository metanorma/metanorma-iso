require "isodoc"

module IsoDoc
  module Csd
    class  Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
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
        stage = STAGE_ABBRS[stage.to_sym] || "??"
        stage += iter.text if iter
        stage = "Pre" + stage if draft&.text =~ /^0\./
        stage
      end

      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//status/stage"))
        if docstatus
          set(:stage, docstatus.text)
          set(:stage_int, docstatus.text.to_i)
          abbr = stage_abbrev(docstatus.text, isoxml.at(ns("//status/iteration")),
                              isoxml.at(ns("//version/draft")))
          set(:stageabbr, abbr)
        end
      end

      def docid(isoxml, _out)
        dn = docnumber(isoxml)
        docstatus = get[:stage]
        if docstatus
          abbr = get[:stageabbr]
          docstatus = get[:stage]
          (docstatus.to_i < 60) && dn = abbr + " " + dn
        end
        set(:docnumber, dn)
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
        intro = isoxml.at(ns("//title-intro[@language='en']"))
        main = isoxml.at(ns("//title-main[@language='en']"))
        part = isoxml.at(ns("//title-part[@language='en']"))
        partnumber = isoxml.at(ns("//project-number/@part"))
        subpartnumber = isoxml.at(ns("//project-number/@subpart"))

        set(:doctitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, "en")
        set(:doctitle, main)
        set(:doctitleintro, @c.encode(intro ? intro.text : "", :hexadecimal)) if intro
        set(:doctitlepart, part_title(part, partnumber, subpartnumber, "en"))
      end

      def subtitle(isoxml, _out)
        intro = isoxml.at(ns("//title-intro[@language='fr']"))
        main = isoxml.at(ns("//title-main[@language='fr']"))
        part = isoxml.at(ns("//title-part[@language='fr']"))
        partnumber = isoxml.at(ns("//project-number/@part"))
        subpartnumber = isoxml.at(ns("//project-number/@subpart"))
        set(:docsubtitlemain, @c.encode(main ? main.text : "", :hexadecimal))
        main = compose_title(main, intro, part, partnumber, subpartnumber, "fr")
        set(:docsubtitle, main)
        set(:docsubtitleintro, @c.encode(intro ? intro.text : "", :hexadecimal)) if intro
        set(:docsubtitlepart, part_title(part, partnumber, subpartnumber, "fr"))
      end
    end
  end
end
