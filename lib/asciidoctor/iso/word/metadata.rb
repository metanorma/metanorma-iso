module Asciidoctor
  module ISO
    module Word
      module Metadata
        @@meta = {}

        def get_metadata
          @@meta
        end

        def author(isoxml, _out)
          # tc = isoxml.at(ns("//technical-committee"))
          tc_num = isoxml.at(ns("//technical-committee/@number"))
          # sc = isoxml.at(ns("//subcommittee"))
          sc_num = isoxml.at(ns("//subcommittee/@number"))
          # wg = isoxml.at(ns("//workgroup"))
          wg_num = isoxml.at(ns("//workgroup/@number"))
          secretariat = isoxml.at(ns("//secretariat"))
          @@meta[:tc] = "XXXX"
          @@meta[:sc] = "XXXX"
          @@meta[:wg] = "XXXX"
          @@meta[:secretariat] = "XXXX"
          @@meta[:tc] = tc_num.text if tc_num
          @@meta[:sc] = sc_num.text if sc_num
          @@meta[:wg] = wg_num.text if wg_num
          @@meta[:secretariat] = secretariat.text if secretariat
        end

        def id(isoxml, _out)
          docnumber = isoxml.at(ns("//projectnumber"))
          partnumber = isoxml.at(ns("//projectnumber/@part"))
          documentstatus = isoxml.at(ns("//status/stage"))
          @@meta[:docnumber] = docnumber.text
          @@meta[:docnumber] += "-#{partnumber.text}" if partnumber
          @@meta[:stage] = documentstatus.text if documentstatus
          @@meta[:stageabbr] =
            Asciidoctor::ISO::ISOXML::Utils::stage_abbreviation(@@meta[:stage])
          if @@meta[:stage].to_i < 60
            @@meta[:docnumber] = @@meta[:stageabbr] + " " + @@meta[:docnumber]
          end
        end

        def version(isoxml, _out)
          # e =  isoxml.at(ns("//edition"))
          # out.p "Edition: #{e.text}" if e
          # e =  isoxml.at(ns("//revision_date"))
          # out.p "Revised: #{e.text}" if e
          yr =  isoxml.at(ns("//copyright/from"))
          @@meta[:docyear] = yr.text
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
          @@meta[:doctitle] = main
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
          @@meta[:docsubtitle] = main
        end
      end
    end
  end
end
