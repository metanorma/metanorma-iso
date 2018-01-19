module Asciidoctor
  module ISO::Word
    module Section

      def clause_parse(node, out)
        out.div **attr_code("id": node["anchor"]) do |s|
          node.children.each do |c1|
            if c1.name == "name"
              s.send "h#{$anchors[node["anchor"]][:level]}" do |h|
                h << "#{$anchors[node["anchor"]][:label]}. #{c1.text}"
              end
            else
              parse(c1, s)
            end
          end
        end
      end

      def clause(isoxml, out)
        clauses = isoxml.xpath(ns("//middle/clause"))
        return unless clauses
        clauses.each do |c|
          out.div **attr_code("id": c["anchor"]) do |s|
            c.elements.each do |c1|
              if c1.name == "name"
                s.h1 do |t|
                  t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}"
                end
              else
                parse(c1, s)
              end
            end
          end
        end
      end

      def annex(isoxml, out)
        clauses = isoxml.xpath(ns("//annex"))
        return unless clauses
        clauses.each do |c|
          out.div **attr_code("id": c["anchor"]) do |s|
            c.elements.each do |c1|
              if c1.name == "name"
                s.h1 do |t|
                  t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}"
                end
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
          div.h1 "1. Scope"
          f.elements.each do |e|
            parse(e, div)
          end
        end
      end

      def terms_defs(isoxml, out)
        f = isoxml.at(ns("//terms_defs"))
        return unless f
        out.div do |div|
          div.h1 "3. Terms and Definitions"
          f.elements.each do |e|
            parse(e, div)
          end
        end
      end

      def symbols_abbrevs(isoxml, out)
        f = isoxml.at(ns("//symbols_abbrevs"))
        return unless f
        out.div do |div|
          div.h1 "4. Symbols and Abbreviations"
          f.elements.each do |e|
            parse(e, div)
          end
        end
      end

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction"))
        return unless f
        title_attr = {class: "IntroTitle",
                      style: "page-break-before:always"}
        out.div do |div|
          div.h1 **attr_code(title_attr) do |p|
            p << "Introduction"
          end
          f.elements.each do |e|
            if e.name == "patent_notice"
              e.elements.each do |e1|
                parse(e1, div)
              end
            else
              parse(e, div)
            end
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword"))
        return unless f
        out.div  do |s|
          s.h1 **{class: "ForewordTitle"} { |h1| h1 << "Foreword" }
=begin
    s.p **{class: "ForewordTitle"} do |p|
      p.a **{name: "_Toc353342667"}
      p.a **{name: "_Toc485815077"} do |a|
        a.span **{style: "mso-bookmark:_Toc353342667"} do |span|
          span.span << "Foreword"
        end
      end
    end
=end
          f.elements.each do |e|
            parse(e, s)
          end
        end
      end
    end
  end
end
