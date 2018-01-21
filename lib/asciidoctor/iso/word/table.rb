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
              thead.children.each { |n| parse(n, h) }
            end
          end
        end

        def tbody_parse(node, t)
          tbody = node.at(ns("./tbody"))
          t.tbody do |h|
            tbody.children.each { |n| parse(n, h) }
          end
        end

        def tfoot_parse(node, t)
          tfoot = node.at(ns("./tfoot"))
          if tfoot
            t.tfoot do |h|
              tfoot.children.each { |n| parse(n, h) }
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

        def make_tr_attr(td)
          {
            rowspan: td["rowspan"],
            colspan: td["colspan"],
            align: td["align"],
          }
        end

        def tr_parse(node, out)
          out.tr do |r|
            node.elements.each do |td|
              r.send td.name, **attr_code(make_tr_attr(td)) do |entry|
                td.children.each { |n| parse(n, entry) }
              end
            end
          end
        end
      end
    end
  end
end
