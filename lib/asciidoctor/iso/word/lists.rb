module Asciidoctor
  module ISO
    module Word
      module Lists
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

        def dl_parse(node, out)
          out.dl do |v|
            node.elements.each_slice(2) do |dt, dd|
              v.dt do |term|
                if dt.elements.empty?
                  term.p **{ class: is_note ? "Note" : "MsoNormal" } do
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
      end
    end
  end
end
