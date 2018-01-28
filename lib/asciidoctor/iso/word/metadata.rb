module Asciidoctor
  module ISO
    module Word
      module Metadata
        def author(isoxml, _out)
          # tc = isoxml.at(ns("//technical-committee"))
          tc_num = isoxml.at(ns("//technical-committee/@number"))
          # sc = isoxml.at(ns("//subcommittee"))
          sc_num = isoxml.at(ns("//subcommittee/@number"))
          # wg = isoxml.at(ns("//workgroup"))
          wg_num = isoxml.at(ns("//workgroup/@number"))
          secretariat = isoxml.at(ns("//secretariat"))
          $iso_tc = "XXXX"
          $iso_sc = "XXXX"
          $iso_wg = "XXXX"
          $iso_secretariat = "XXXX"
          $iso_tc = tc_num.text if tc_num
          $iso_sc = sc_num.text if sc_num
          $iso_wg = wg_num.text if wg_num
          $iso_secretariat = secretariat.text if secretariat
        end

        def id(isoxml, _out)
          docnumber = isoxml.at(ns("//projectnumber"))
          partnumber = isoxml.at(ns("//projectnumber/@part"))
          documentstatus = isoxml.at(ns("//status/stage"))
          $iso_docnumber = docnumber.text
          $iso_docnumber += "-#{partnumber.text}" if partnumber
          $iso_stage = documentstatus.text if documentstatus
          $iso_stageabbr =
            Asciidoctor::ISO::ISOXML::Utils::stage_abbreviation($iso_stage)
          if $iso_stage.to_i < 60
            $iso_docnumber = $iso_stageabbr + " " + $iso_docnumber
          end
        end

        def version(isoxml, _out)
          # e =  isoxml.at(ns("//edition"))
          # out.p "Edition: #{e.text}" if e
          # e =  isoxml.at(ns("//revision_date"))
          # out.p "Revised: #{e.text}" if e
          yr =  isoxml.at(ns("//copyright/from"))
          $iso_docyear = yr.text
          # out.p "© ISO #{yr.text}" if yr
        end

        def title(isoxml, _out)
          intro = isoxml.at(ns("//title[@language='en']/title-intro"))
          main = isoxml.at(ns("//title[@language='en']/title-main"))
          part = isoxml.at(ns("//title[@language='en']/title-part"))
          partnumber = isoxml.at(ns("//id/projectnumber/@part"))
          main = main.text
          main = "#{intro.text}&nbsp;&mdash;#{main}" if intro
          if part
            main = "#{main}&nbsp;&mdash; Part&nbsp;#{partnumber}: #{part.text}"
          end
          $iso_doctitle = main
        end

        def subtitle(isoxml, _out)
          intro = isoxml.at(ns("//title[@language='fr']/title-intro"))
          main = isoxml.at(ns("//title[@language='fr']/title-main"))
          part = isoxml.at(ns("//title[@language='fr']/title-part"))
          partnumber = isoxml.at(ns("//id/projectnumber/@part"))
          main = main.text
          main = "#{intro.text}&nbsp; #{main}" if intro
          if part
            main = "#{main}&nbsp;&mdash; Part&nbsp;#{partnumber}: #{part.text}"
          end
          $iso_docsubtitle = main
        end
      end
    end
  end
end
