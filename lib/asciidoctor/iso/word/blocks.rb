require "uuidtools"

module Asciidoctor
  module ISO::Word
    module Blocks
      def ul_parse(node, out)
        out.ul do |ul|
          node.children.each { |n| parse(n, ul) }
        end
      end

      def ol_parse(node, out)
        attrs = {numeration: node["type"] }
        out.ol **attr_code(attrs) do |ol|
          node.children.each { |n| parse(n, ol) }
        end
      end

      def note_parse(node, out)
        out.div **attr_code("id": node["anchor"],
                            class: "MsoNormalIndent" ) do |t|
          node.children.each { |n| parse(n, t) }
        end
      end

      def figure_parse(node, out)
        name = node.at(ns("./name"))
        out.div **attr_code(id: node["anchor"]) do |div|
          if node["src"]
            image_parse(node["src"], div, nil)
          end
          node.children.each do |n|
            parse(n, div) unless n.name == "name"
          end
          if name
            div.p **{class: "FigureTitle",
                     align: "center",
            } do |p|
              p.b do |b|
                b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; "
                b << name.text
              end
            end
          end
        end
      end

      def warning_parse(node, out)
        name = node.at(ns("./name"))
        out.div **{class: "MsoBlockText"} do |t|
          if name
            t.p do |tt|
              tt.b { |b| b << name.text }
            end
          end
          node.children.each do |n|
            parse(n, t) unless n.name == "name"
          end
        end
      end

      def formula_parse(node, out)
        stem = node.at(ns("./stem"))
        dl = node.at(ns("./dl"))
        out.div **attr_code(id: node["anchor"], class: "formula") do |div|
          parse(stem, out)
          div.span **attr_code(style: "mso-tab-count:1") do |span|
            span << "&#xA0; "
          end
          div << "(#{$anchors[node["anchor"]][:label]})"
        end
        out.p { |p| p << "where" }
        parse(dl, out) if dl
      end

      def para_parse(node, out)
        out.p **{class: "MsoNormal"} do |p|
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
              dt.children.each { |n| parse(n, term) }
            end
            v.dd do |listitem|
              dd.children.each { |n| parse(n, listitem) }
            end
          end
        end
      end

      def image_parse(url, out, caption)
        orig_filename = url
        matched = /\.(?<suffix>\S+)$/.match orig_filename
        uuid = UUIDTools::UUID.random_create
        new_filename = "#{uuid.to_s[0..17]}.#{matched[:suffix]}"
        new_full_filename = File.join($dir, new_filename)
        system "cp #{orig_filename} #{new_full_filename}"
        image_size = ImageSize.path(orig_filename).size
        # max width is 400
        if image_size[0] > 400
          image_size[1] = (image_size[1] * 400 / image_size[0]).ceil
          image_size[0] = 400
        end
        # TODO ditto max height
        out.img **attr_code(src: new_full_filename,
                            height: image_size[1],
                            width: image_size[0])
        unless caption.nil?
          out.p **{class: "FigureTitle", align: "center"} do |p|
            p.b do |b|
              b << "#{caption}"
            end
          end
        end
      end

      def table_parse(node, out)
        table_attr = {id: node["anchor"],
                      class: "MsoISOTable",
                      border: 1,
                      cellspacing: 0,
                      cellpadding: 0,
        }
        name = node.at(ns("./name"))
        if name
          out.p **{class: "TableTitle",
                   align: "center",
          } do |p|
            p.b do |b|
              b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; "
              b << name.text
            end
          end
        end
        out.table **attr_code(table_attr) do |t|
          thead = node.at(ns("./thead"))
          tbody = node.at(ns("./tbody"))
          tfoot = node.at(ns("./tfoot"))
          dl = node.at(ns("./dl"))
          note = node.xpath(ns("./note"))
          if thead
            t.thead do |h|
              thead.children.each { |n| parse(n, h) }
            end
          end
          t.tbody do |h|
            tbody.children.each { |n| parse(n, h) }
          end
          if tfoot
            t.tfoot do |h|
              tfoot.children.each { |n| parse(n, h) }
            end
          end
          parse(dl, out) if dl
          note.each { |n| parse(n, out) }
        end
      end

      def tr_parse(node, out)
        out.tr do |r|
          node.elements.each do |td|
            attrs = {
              rowspan: td["rowspan"],
              colspan: td["colspan"],
              align: td["align"],
            }
            r.send td.name, **attr_code(attrs) do |entry|
              td.children.each { |n| parse(n, entry) }
            end
          end
        end
      end
    end
  end
end

