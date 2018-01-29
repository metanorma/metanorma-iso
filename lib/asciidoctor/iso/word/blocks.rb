require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module Blocks
        @@termdomain = ""
        @@termexample = false
        @@note = false
        @@sourcecode = false

        def set_termdomain(termdomain)
          @@termdomain = termdomain
        end

        def get_termexample
          @@termexample
        end

        def set_termexample(value)
          @@termexample = value
        end

        def in_sourcecode
          @@sourcecode
        end

        def ul_parse(node, out)
          out.ul do |ul|
            node.children.each { |n| parse(n, ul) }
          end
        end

        @@ol_style = {
          arabic: "1",
          roman: "i",
          alphabet: "a",
          roman_upper: "I",
          alphabet_upper: "A",
        }.freeze

        def ol_style(type)
          style = @@ol_style[type.to_sym]
          #ret = nil
          #ret = "mso-level-number-format: #{style};" unless style.empty?
          style
        end

        def ol_parse(node, out)
          # attrs = { numeration: node["type"] }
          style = ol_style(node["type"])
          out.ol **attr_code(type: style) do |ol|
            node.children.each { |n| parse(n, ol) }
          end
        end

        def note_p_parse(node, div)
          div.p **{ class: "Note" } do |p|
            p << "NOTE"
            insert_tab(p, 1)
            node.first_element_child.children.each { |n| parse(n, p) }
          end
          node.element_children[1..-1].each { |n| parse(n, div) }
        end

        def note_parse(node, out)
          @@note = true
          out.div **{ id: node["id"], class: "Note" } do |div|
            if node.first_element_child.name == "p"
              note_p_parse(node, div)
            else
              div.p **{ class: "Note" } do |p|
                p << "NOTE"
                insert_tab(p, 1)
              end
              node.children.each { |n| parse(n, div) }
            end
          end
          @@note = false
        end

        def figure_name_parse(node, div, name)
          div.p **{ class: "FigureTitle", align: "center" } do |p|
            p.b do |b|
              b << "#{get_anchors()[node['id']][:label]}&nbsp;&mdash; "
              b << name.text
            end
          end
        end

        def figure_key(out)
          out.p **{ class: "MsoNormal" } do |p| 
            p.b { |b| b << "Key" }
          end
        end

        def figure_parse(node, out)
          name = node.at(ns("./name"))
          out.div **attr_code(id: node["id"]) do |div|
            node.children.each do |n|
              figure_key(out) if n.name == "dl"
              parse(n, div) unless n.name == "name"
            end
            figure_name_parse(node, div, name) if name
          end
        end

        def sourcecode_name_parse(node, div, name)
          div.p **{ class: "FigureTitle", align: "center" } do |p|
            p.b do |b|
              b << name.text
            end
          end
        end

        def sourcecode_parse(node, out)
          name = node.at(ns("./name"))
          out.p **attr_code(id: node["id"], class: "Sourcecode") do |div|
            @@sourcecode = true
            node.children.each do |n|
              parse(n, div) unless n.name == "name"
            end
            @@sourcecode = false
            sourcecode_name_parse(node, div, name) if name
          end
        end

        def annotation_parse(node, out)
          out.p **{ class: "Sourcecode" } do |li|
            node.children.each { |n| parse(n, li) }
          end
        end

        def admonition_parse(node, out)
          name = node["type"]
          out.div **{ class: "MsoBlockText" } do |t|
            t.p.b { |b| b << name.upcase } if name
            node.children.each do |n|
              parse(n, t)
            end
          end
        end

        def formula_parse(node, out)
          dl = node.at(ns("./dl"))
          out.div **attr_code(id: node["id"], class: "formula") do |div|
            parse(node.at(ns("./stem")), out)
            insert_tab(div, 1)
            div << "(#{get_anchors()[node['id']][:label]})"
          end
          if dl
            out.p **{ class: "MsoNormal" } { |p| p << "where" }
            parse(dl, out) 
          end
        end

        def para_attrs(node)
          classtype = "MsoNormal"
          classtype = "Note" if @@note
          classtype = "MsoFootnoteText" if in_footnote
          attrs = { class: classtype }
          unless node["align"].nil?
            attrs[:align] = node["align"] unless node["align"] == "justify"
            attrs[:style] = "text-align:#{node["align"]}"
          end
          attrs
        end

        def para_parse(node, out)
          out.p **attr_code(para_attrs(node)) do |p|
            unless @@termdomain.empty?
              p << "&lt;#{@@termdomain}&gt; "
              @@termdomain = ""
            end
            node.children.each { |n| parse(n, p) }
          end
        end

        def quote_attribution(node, out)
          author = node.at(ns("./author/fullname/"))
          source = node.at(ns("./source"))
          # TODO implement
        end

        def quote_parse(node, out)
          attrs = para_attrs(node)
          attrs[:class] = "MsoNormalIndent"
          out.p **attr_code(attrs) do |p|
            node.children.each do 
              |n| parse(n, p) unless ["author", "source"].include? n.name
            end
            quote_attribution(node, out)
          end
        end

        def dl_parse(node, out)
          out.dl do |v|
            node.elements.each_slice(2) do |dt, dd|
              v.dt do |term|
                if dt.elements.empty?
                  term.p **{ class: @@note ? "Note" : "MsoNormal" } do
                    |p| p << dt.text 
                  end
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
          # max width for Word document is 400, max height is 680
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
      end
    end
  end
end
