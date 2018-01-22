require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module ISOXML
      module Cleanup
        class << self
          def cleanup(xmldoc)
            termdef_cleanup(xmldoc)
            isotitle_cleanup(xmldoc)
            table_cleanup(xmldoc)
            formula_cleanup(xmldoc)
            figure_cleanup(xmldoc)
            ref_cleanup(xmldoc)
            review_note_cleanup(xmldoc)
            xmldoc
          end

          def termdef_warn(text, re, term, msg)
            if re.match? text
              warn "ISO style: #{term}: #{msg}"
            end
          end

          def termdef_style(xmldoc)
            xmldoc.xpath("//termdef").each do |t|
              para = t.at("./p")
              return if para.nil?
              term = t.at("term").text
              termdef_warn(para.text, /^(the|a)\b/i, term,
                           "term definition starts with article")
              termdef_warn(para.text, /\.$/i, term,
                           "term definition ends with period")
            end
          end

          def termdef_stem_cleanup(xmldoc)
            xmldoc.xpath("//termdef/p/stem").each do |a|
              if a.parent.elements.size == 1
                # para containing just a stem expression
                t = Nokogiri::XML::Element.new("termsymbol", xmldoc)
                parent = a.parent
                t.children = a.remove
                parent.replace(t)
              end
            end
          end

          def termdomain_cleanup(xmldoc)
            xmldoc.xpath("//p/termdomain").each do |a|
              prev = a.parent.previous
              prev.next = a.remove
            end
          end

          def termdefinition_cleanup(xmldoc)
            xmldoc.xpath("//termdef").each do |d|
              first_child = d.at("./p | ./figure | ./formula")
              return if first_child.nil?
              t = Nokogiri::XML::Element.new("termdefinition", xmldoc)
              first_child.replace(t)
              t << first_child.remove
              d.xpath("./p | ./figure | ./formula").each do |n|
                t << n.remove
              end
            end
          end

          def termdef_unnest_cleanup(xmldoc)
            # release termdef tags from surrounding paras
            nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol |
                             //p/deprecated_term")
            while !nodes.empty?
              nodes[0].parent.replace(nodes[0].parent.children)
              nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol |
                               //p/deprecated_term")
            end
          end

          def termdef_cleanup(xmldoc)
            termdef_unnest_cleanup(xmldoc)
            termdef_stem_cleanup(xmldoc)
            termdomain_cleanup(xmldoc)
            termdefinition_cleanup(xmldoc)
            termdef_style(xmldoc)
          end

          def isotitle_cleanup(xmldoc)
            # Remove italicised ISO titles
            xmldoc.xpath("//isotitle").each do |a|
              if a.elements.size == 1 && a.elements[0].name == "em"
                a.children = a.elements[0].children
              end
            end
          end

          def dl_table_cleanup(xmldoc)
            # move Key dl after table footer
            q = "//table/following-sibling::*[1]"\
              "[self::p and normalize-space() = 'Key']"
            xmldoc.xpath(q).each do |s|
              if !s.next_element.nil? && s.next_element.name == "dl"
                s.previous_element << s.next_element.remove
                s.remove
              end
            end
          end

          def table_cleanup(xmldoc)
            dl_table_cleanup(xmldoc)
            notes_table_cleanup(xmldoc)
          end

          def notes_table_cleanup(xmldoc)
            # move notes into table
            nomatches = false
            until nomatches
              q = "//table/following-sibling::*[1][self::note]"
              nomatches = true
              xmldoc.xpath(q).each do |n|
                n.previous_element << n.remove
                nomatches = false
              end
            end
          end

          def formula_cleanup(x)
            # include where definition list inside stem block
            q = "//formula/following-sibling::*[1]"\
              "[self::p and text() = 'where']"
            x.xpath(q).each do |s|
              if !s.next_element.nil? && s.next_element.name == "dl"
                s.previous_element << s.next_element.remove
                s.remove
              end
            end
          end

          # include footnotes inside figure
          def figure_footnote_cleanup(xmldoc)
            nomatches = false
            until nomatches
              q = "//figure/following-sibling::*[1][self::p and *[1][self::fn]]"
              nomatches = true
              xmldoc.xpath(q).each do |s|
                s.previous_element << s.first_element_child.remove
                s.remove
                nomatches = false
              end
            end
          end

          def figure_dl_cleanup(xmldoc)
            # include key definition list inside figure
            q = "//figure/following-sibling::*"\
              "[self::p and normalize-space() = 'Key']"
            xmldoc.xpath(q).each do |s|
              if !s.next_element.nil? && s.next_element.name == "dl"
                s.previous_element << s.next_element.remove
                s.remove
              end
            end
          end

          def subfigure_cleanup(xmldoc)
            # examples containing only figures become subfigures of figures
            nodes = xmldoc.xpath("//example/figure")
            while !nodes.empty?
              nodes[0].parent.name = "figure"
              nodes = xmldoc.xpath("//example/figure")
            end
          end

          def figure_cleanup(xmldoc)
            figure_footnote_cleanup(xmldoc)
            figure_dl_cleanup(xmldoc)
            subfigure_cleanup(xmldoc)
          end

          def ref_cleanup(xmldoc)
            # move ref before p
            xmldoc.xpath("//p/ref").each do |r|
              parent = r.parent
              parent.previous = r.remove
            end
            xmldoc
          end

          def review_note_cleanup(xmldoc)
            xmldoc.xpath("//review_note").each do |n|
              prev = n.previous_element
              if !prev.nil? && prev.name == "p"
                n.parent = prev
              end
            end
          end
        end
      end
    end
  end
end
