require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module Blocks
        def ul_parse(node, out)
          out.ul do |ul|
            node.children.each { |n| parse(n, ul) }
          end
        end

        def ol_parse(node, out)
          attrs = { numeration: node["type"] }
          out.ol **attr_code(attrs) do |ol|
            node.children.each { |n| parse(n, ol) }
          end
        end

        def note_parse(node, out)
          out.div **attr_code("id": node["anchor"],
                              class: "MsoNormalIndent") do |t|
            node.children.each { |n| parse(n, t) }
          end
        end

        def figure_name_parse(node, div, name)
          div.p **{ class: "FigureTitle", align: "center" } do |p|
            p.b do |b|
              b << "#{$anchors[node['anchor']][:label]}&nbsp;&mdash; "
              b << name.text
            end
          end
        end

        def figure_parse(node, out)
          name = node.at(ns("./name"))
          out.div **attr_code(id: node["anchor"]) do |div|
            image_parse(node["src"], div, nil) if node["src"]
            node.children.each do |n|
              parse(n, div) unless n.name == "name"
            end
            figure_name_parse(node, div, name) if name
          end
        end

        def warning_parse(node, out)
          name = node.at(ns("./name"))
          out.div **{ class: "MsoBlockText" } do |t|
            t.p.b { |b| b << name.text } if name
            node.children.each do |n|
              parse(n, t) unless n.name == "name"
            end
          end
        end

        def formula_parse(node, out)
          dl = node.at(ns("./dl"))
          out.div **attr_code(id: node["anchor"], class: "formula") do |div|
            parse(node.at(ns("./stem")), out)
            insert_tab(div, 1)
            div << "(#{$anchors[node['anchor']][:label]})"
          end
          out.p **{ class: "MsoNormal" } { |p| p << "where" }
          parse(dl, out) if dl
        end

        def para_parse(node, out)
          out.p **{ class: "MsoNormal" } do |p|
            unless $termdomain.empty?
              p << "&lt;#{$termdomain}&gt; "
              $termdomain = ""
            end
            $block = true
            node.children.each { |n| parse(n, p) }
            $block = false
          end
        end

        def dl_parse(node, out)
          out.dl do |v|
            node.elements.each_slice(2) do |dt, dd|
              v.dt do |term|
                if dt.elements.empty?
                  term.p **{ class: "MsoNormal" } { |p| p << dt.text }
                else
                  dt.children.each { |n| parse(n, term) }
                end
              end
              v.dd do |listitem|
                dd.children.each { |n| parse(n, listitem) }
              end
            end
          end
        end

        def image_resize(orig_filename)
          image_size = ImageSize.path(orig_filename).size
          # max width is 400, max height is 680
          if image_size[0] > 400
            image_size[1] = (image_size[1] * 400 / image_size[0]).ceil
            image_size[0] = 400
          end
          if image_size[1] > 680
            image_size[0] = (image_size[0] * 680 / image_size[1]).ceil
            image_size[1] = 680
          end
          image_size
        end

        def image_title_parse(out, caption)
          unless caption.nil?
            out.p **{ class: "FigureTitle", align: "center" } do |p|
              p.b do |b|
                b << caption.to_s
              end
            end
          end
        end

        def image_parse(url, out, caption)
          matched = /\.(?<suffix>\S+)$/.match url
          uuid = UUIDTools::UUID.random_create
          new_filename = "#{uuid.to_s[0..17]}.#{matched[:suffix]}"
          new_full_filename = File.join($dir, new_filename)
          system "cp #{url} #{new_full_filename}"
          image_size = image_resize(url)
          out.img **attr_code(src: new_full_filename,
                              height: image_size[1],
                              width: image_size[0])
          image_title_parse(out, caption)
        end

        def table_title_parse(node, out)
          name = node.at(ns("./name"))
          if name
            out.p **{ class: "TableTitle", align: "center" } do |p|
              p.b do |b|
                b << "#{$anchors[node['anchor']][:label]}&nbsp;&mdash; "
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
