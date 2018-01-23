module Asciidoctor
  module ISO
    module Word
      module Section
        def clause_parse(node, out)
          out.div **attr_code("id": node["anchor"]) do |s|
            node.children.each do |c1|
              if c1.name == "title"
                s.send "h#{get_anchors()[node['anchor']][:level]}" do |h|
                  h << "#{get_anchors()[node['anchor']][:label]}. #{c1.text}"
                end
              else
                parse(c1, s)
              end
            end
          end
        end

        def clause_name(num, title, div)
          div.h1 do |h1|
            h1 << num
            insert_tab(h1, 1)
            h1 << title
          end
        end

        def clause(isoxml, out)
          # isoxml.xpath(ns("//middle/clause")).each do |c|
          isoxml.xpath(ns("//clause[parent::sections]")).each do |c|
            out.div **attr_code("id": c["anchor"]) do |s|
              c.elements.each do |c1|
                if c1.name == "title"
                  clause_name("#{get_anchors()[c['anchor']][:label]}.", c1.text, s)
                else
                  parse(c1, s)
                end
              end
            end
          end
        end

        def annex_name(annex, name, div)
          div.h1 **{class: "Annex"} do |t|
            t << "#{get_anchors()[annex['anchor']][:label]}<br/><br/>"
            t << "<b>#{name.text}</b>"
          end
        end

        def annex(isoxml, out)
          isoxml.xpath(ns("//annex")).each do |c|
            page_break(out)
            out.div **attr_code("id": c["anchor"], class: "Section3" ) do |s|
              c.elements.each do |c1|
                if c1.name == "title"
                  annex_name(c, c1, s)
                else
                  parse(c1, s)
                end
              end
            end
          end
        end

        def scope(isoxml, out)
          f = isoxml.at(ns("//scope"))
          return unless f
          out.div do |div|
              clause_name("1.", "Scope", div)
            f.elements.each do |e|
              parse(e, div)
            end
          end
        end

        def terms_defs(isoxml, out)
          f = isoxml.at(ns("//terms_defs"))
          return unless f
          out.div do |div|
              clause_name("3.", "Terms and Definitions", div)
              f.elements.each do |e|
                parse(e, div)
              end
            end
          end

          def symbols_abbrevs(isoxml, out)
            f = isoxml.at(ns("//symbols_abbrevs"))
            return unless f
            out.div do |div|
              clause_name("4.", "Symbols and Abbreviations", div)
              f.elements.each do |e|
                parse(e, div)
              end
            end
          end

          def introduction(isoxml, out)
            f = isoxml.at(ns("//introduction"))
            return unless f
            title_attr = { class: "IntroTitle" }
            page_break(out)
            out.div **{class: "Section3" } do |div|
              div.h1 "Introduction", **attr_code(title_attr)
              f.elements.each do |e|
                if e.name == "patent_notice"
                  e.elements.each { |e1| parse(e1, div) }
                else
                  parse(e, div)
                end
              end
            end
          end

          def foreword(isoxml, out)
            f = isoxml.at(ns("//foreword"))
            return unless f
            out.div do |s|
              s.h1 **{ class: "ForewordTitle" } { |h1| h1 << "Foreword" }
              f.elements.each { |e| parse(e, s) }
            end
          end
        end
      end
    end
  end
