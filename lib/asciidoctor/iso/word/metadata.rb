module Asciidoctor
  module ISO::Word
    module Metadata
      def author(isoxml, out)
        tc = isoxml.at(ns("//technical_committee"))
        tc_num = isoxml.at(ns("//technical_committee/@number"))
        sc = isoxml.at(ns("//subcommittee"))
        sc_num = isoxml.at(ns("//subcommittee/@number"))
        wg = isoxml.at(ns("//workgroup"))
        wg_num = isoxml.at(ns("//workgroup/@number"))
        secretariat = isoxml.at(ns("//secretariat"))
        ret = tc.text
        ret = "ISO TC #{tc_num.text}: #{ret}" if tc_num
        ret += " SC #{sc_num.text}:" if sc_num
        ret += " #{sc.text}" if sc
        ret += " WG #{wg_num.text}:" if wg_num
        ret += " #{wg.text}" if wg
        $iso_tc = "XXXX"
        $iso_sc = "XXXX"
        $iso_wg = "XXXX"
        $iso_secretariat = "XXXX"
        $iso_tc = tc_num.text if tc_num
        $iso_sc = sc_num.text if sc_num
        $iso_wg = wg_num.text if wg_num
        $iso_secretariat = secretariat.text if secretariat
        # out.p ret
      end

      def id(isoxml, out)
        docnumber = isoxml.at(ns("//documentnumber"))
        partnumber = isoxml.at(ns("//documentnumber/@partnumber"))
        documentstatus = isoxml.at(ns("//documentstatus/stage"))
        ret = "ISO #{docnumber.text}"
        ret += "-#{partnumber.text}" if partnumber
        $iso_docnumber = docnumber.text
        $iso_docnumber += "-#{partnumber.text}" if partnumber
        $iso_stage = documentstatus.text if documentstatus
        $iso_stageabbr =
          Asciidoctor::ISO::ISOXML::Utils::stage_abbreviation($iso_stage)
        if $iso_stage.to_i < 60
          $iso_docnumber = $iso_stageabbr + " " + $iso_docnumber
        end
      end

      def version(isoxml, out)
        e =  isoxml.at(ns("//edition"))
        # out.p "Edition: #{e.text}" if e
        e =  isoxml.at(ns("//revdate"))
        # out.p "Revised: #{e.text}" if e
        yr =  isoxml.at(ns("//copyright_year"))
        $iso_docyear = yr.text
        # out.p "© ISO #{yr.text}" if yr
      end

      def title(isoxml, out)
        out.p **{class: "MsoTitle"} do |t|
          intro = isoxml.at(ns("//title/en/title_intro"))
          main = isoxml.at(ns("//title/en/title_main"))
          part = isoxml.at(ns("//title/en/title_part"))
          partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
          main = main.text
          main = "#{intro.text} — #{main}" if intro
          main = "#{main} — Part #{partnumber}: #{part.text}" if part
          $iso_doctitle = main
        end
      end

      def subtitle(isoxml, out)
        out.p **{class: "MsoSubtitle"} do |t|
          intro = isoxml.at(ns("//title/fr/title_intro"))
          main = isoxml.at(ns("//title/fr/title_main"))
          part = isoxml.at(ns("//title/fr/title_part"))
          partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
          main = main.text
          main = "#{intro.text} — #{main}" if intro
          main = "#{main} — Part #{partnumber}: #{part.text}" if part
          $iso_docsubtitle = main
        end
      end

    end
  end
end

