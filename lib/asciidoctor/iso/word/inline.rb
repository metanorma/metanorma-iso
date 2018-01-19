require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module Inline
        def section_break(body)
          body.br **{ clear: "all", class: "section" }
        end

        def eref_parse(node, out)
          linktext = node.text
          linktext = node["target"] if linktext.empty?
          out.a **{ "href": node["target"] } { |l| l << linktext }
        end

        def li_parse(node, out)
          out.li **{ class: "MsoNormal" } do |li|
            node.children.each { |n| parse(n, li) }
          end
        end

        def get_linkend(node)
          linkend = node["target"]
          if $anchors.has_key? node["target"]
            linkend = $anchors[node["target"]][:xref]
          end
          linkend = node.text unless node.text.empty?
          linkend
        end

        def xref_parse(node, out)
          linkend = get_linkend(node)
          if node["format"] == "footnote"
            out.sup do |s|
              s.a **{ "href": node["target"] } { |l| l << linkend }
            end
          else
            out.a **{ "href": node["target"] } { |l| l << linkend }
          end
        end

        def stem_parse(node, out)
          $xslt.xml = AsciiMath.parse(node.text).to_mathml.
            gsub(/<math>/,
                 "<math xmlns='http://www.w3.org/1998/Math/MathML'>")
          ooml = $xslt.serve.gsub(/<\?[^>]+>\s*/, "").
            gsub(/ xmlns:[^=]+="[^"]+"/, "")
          out.span **{ class: "stem" } do |span|
            span.parent.add_child ooml
          end
        end

        def error_parse(node, out)
          text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
          if $block
            out.b **{ role: "strong" } { |e| e << text }
          else
            out.para do |p|
              p.b **{ role: "strong" } { |e| e << text }
            end
          end
        end

        def footnotes(div)
          div.div **{ style: "mso-element:footnote-list" } do |div1|
            $footnotes.each do |fn|
              div1.parent << fn
            end
          end
        end

        def footnote_attributes(fn)
          {
            style: "mso-footnote-id:ftn#{fn}",
            href: "#_ftn#{fn}",
            name: "_ftnref#{fn}",
            title: "",
          }
        end

        def make_footnote_link(a)
          a.span **{ class: "MsoFootnoteReference" } do |span|
            span.span **{ style: "mso-special-character:footnote" }
          end
        end

        def make_footnote_text(node, fn)
          noko do |xml|
            xml.div **{ style: "mso-element:footnote", id: "ftn#{fn}" } do |div|
              div.p **{ class: "MsoFootnoteText" } do |p|
                p.a **footnote_attributes(fn) do |a|
                  make_footnote_link(a)
                  node.children.each { |n| parse(n, p) }
                end
              end
            end
          end.join("\n")
        end

        def footnote_parse(node, out)
          fn = $footnotes.length + 1
          out.a **footnote_attributes(fn) { |a| make_footnote_link(a) }
          $footnotes << make_footnote_text(node, fn)
        end
      end
    end
  end
end
