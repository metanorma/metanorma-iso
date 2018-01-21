require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module Table
        def table_title_parse(node, out)
          name = node.at(ns("./name"))
          if name
            out.p **{ class: "TableTitle", align: "center" } do |p|
              p.b do |b|
                b << "#{get_anchors()[node['anchor']][:label]}&nbsp;&mdash; "
                b << name.text
              end
            end
          end
        end

        def thead_parse(node, t)
          thead = node.at(ns("./thead"))
          if thead
            t.thead do |h|
              thead.element_children.each_with_index do |n, i|
                tr_parse(n, h, i, thead.element_children.size)
              end
            end
          end
        end

        def tbody_parse(node, t)
          tbody = node.at(ns("./tbody"))
          t.tbody do |h|
            tbody.element_children.each_with_index do |n, i|
              tr_parse(n, h, i, tbody.element_children.size)
            end
          end
        end

        def tfoot_parse(node, t)
          tfoot = node.at(ns("./tfoot"))
          if tfoot
            t.tfoot do |h|
              tfoot.element_children.each_with_index do |n, i|
                tr_parse(n, h, i, tfoot.element_children.size)
              end
            end
          end
        end

        def make_table_attr(node)
          {
            id: node["anchor"],
            class: "MsoISOTable",
            border: 1,
            cellspacing: 0,
            cellpadding: 0,
          }
        end

        def table_parse(node, out)
          table_title_parse(node, out)
          out.table **make_table_attr(node) do |t|
            thead_parse(node, t)
            tbody_parse(node, t)
            tfoot_parse(node, t)
            dl = node.at(ns("./dl"))
            parse(dl, out) if dl
            node.xpath(ns("./note")).each { |n| parse(n, out) }
          end
        end

        def make_tr_attr(td, row, totalrows, col, totalcols)
          style = ""
          style += td.name == "th" ? "font-weight:bold;" : ""
          style += <<~STYLE
          border-left:#{col.zero? ? "solid windowtext 1.5pt;" : "none;"}
          border-right:solid windowtext #{col == totalcols ? "1.5" : "1.0"}pt;
          border-top:#{row.zero? ? "solid windowtext 1.5pt;" : "none;"}
          border-bottom:solid windowtext #{row == totalrows ? "1.5" : "1.0"}pt;
          STYLE
          { rowspan: td["rowspan"], colspan: td["colspan"],
            align: td["align"], style: style.gsub(/\n/, "") }
        end

        def tr_parse(node, out, ord, totalrows)
          out.tr do |r|
            node.elements.each_with_index do |td, i|
              attrs = make_tr_attr(td, ord, totalrows - 1, 
                                   i, node.elements.size - 1)
              r.send td.name, **attr_code(attrs) do |entry|
                td.children.each { |n| parse(n, entry) }
              end
            end
          end
        end
      end
    end
  end
end
