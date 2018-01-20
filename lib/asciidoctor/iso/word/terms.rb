require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module Terms
        def modification_parse(node, out)
          out << "[MODIFICATION]"
          node.children.each { |n| parse(n, out) }
        end

        def deprecated_term_parse(node, out)
          out.p **{ class: "AltTerms" } do |p|
            p << "DEPRECATED: #{node.text}"
          end
        end

        def termsymbol_parse(node, out)
          out.p **{ class: "AltTerms" } do |p|
            node.children.each { |n| parse(n, p) }
          end
        end

        def admitted_term_parse(node, out)
          out.p **{ class: "AltTerms" } { |p| p << node.text }
        end

        def term_parse(node, out)
          out.p **{ class: "Terms" } { |p| p << node.text }
        end

        def termexample_parse(node, out)
          out.p **{ class: "Note" } do |p|
            p << "EXAMPLE:"
            insert_tab(p, 1)
            node.children.each { |n| parse(n, p) }
          end
        end

        def termnote_parse(node, out)
          out.p **{ class: "Note" } do |p|
            $termnotenumber += 1
            p << "Note #{$termnotenumber} to entry: "
            node.children.each { |n| parse(n, p) }
          end
        end

        def termref_parse(node, out)
          out.p **{ class: "MsoNormal" } do |p|
            p << "[TERMREF]"
            node.children.each { |n| parse(n, p) }
            p << "[/TERMREF]"
          end
        end

        def termdef_parse(node, out)
          out.p **{ class: "TermNum", id: node["anchor"] } do |p|
            p << $anchors[node["anchor"]][:label]
          end
          $termdomain = ""
          $termnotenumber = 0
          node.children.each { |n| parse(n, out) }
        end
      end
    end
  end
end
