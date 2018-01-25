module Asciidoctor
  module ISO
    module Word
      module Section
        def clause_parse(node, out)
          out.div **attr_code("id": node["id"]) do |s|
            node.children.each do |c1|
              if c1.name == "title"
                s.send "h#{get_anchors()[node['id']][:level]}" do |h|
                  h << "#{get_anchors()[node['id']][:label]}. #{c1.text}"
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
          isoxml.xpath(ns("//clause[parent::sections]")).each do |c|
            next if c.at(ns("./title")).text == "Scope"
            out.div **attr_code("id": c["id"]) do |s|
              c.elements.each do |c1|
                if c1.name == "title"
                  clause_name("#{get_anchors()[c['id']][:label]}.", 
                              c1.text, s)
                else
                  parse(c1, s)
                end
              end
            end
          end
        end

        def annex_name(annex, name, div)
          div.h1 **{class: "Annex"} do |t|
            t << "#{get_anchors()[annex['id']][:label]}<br/><br/>"
            t << "<b>#{name.text}</b>"
          end
        end

        def annex(isoxml, out)
          isoxml.xpath(ns("//annex")).each do |c|
            page_break(out)
            out.div **attr_code("id": c["id"], class: "Section3" ) do |s|
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
          f = isoxml.at(ns("//clause[title = 'Scope']")) or return
          out.div do |div|
            clause_name("1.", "Scope", div)
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end

        def terms_defs(isoxml, out)
          f = isoxml.at(ns("//terms")) or return
          out.div do |div|
            clause_name("3.", "Terms and Definitions", div)
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end

        def symbols_abbrevs(isoxml, out)
          f = isoxml.at(ns("//symbols_abbrevs")) or return
          out.div do |div|
            clause_name("4.", "Symbols and Abbreviations", div)
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end

        def introduction(isoxml, out)
          f = isoxml.at(ns("//content[title = 'Introduction']")) or return
          title_attr = { class: "IntroTitle" }
          page_break(out)
          out.div **{class: "Section3" } do |div|
            div.h1 "Introduction", **attr_code(title_attr)
            f.elements.each do |e|
              if e.name == "patent_notice"
                e.elements.each { |e1| parse(e1, div) }
              else
                parse(e, div) unless e.name == "title"
              end
            end
          end
        end

        def foreword(isoxml, out)
          f = isoxml.at(ns("//content[title = 'Foreword']")) or return
          out.div do |s|
            s.h1 **{ class: "ForewordTitle" } { |h1| h1 << "Foreword" }
            f.elements.each { |e| parse(e, s) unless e.name == "title" }
          end
        end
      end
    end
  end
end
