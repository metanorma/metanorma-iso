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
            intro_cleanup(xmldoc)
            termdef_cleanup(xmldoc)
            isotitle_cleanup(xmldoc)
            table_cleanup(xmldoc)
            formula_cleanup(xmldoc)
            figure_cleanup(xmldoc)
            back_cleanup(xmldoc)
            ref_cleanup(xmldoc)
            xmldoc
          end

          def intro_cleanup(xmldoc)
            intro = xmldoc.at("//introduction")
            foreword = xmldoc.at("//foreword")
            front = xmldoc.at("//front")
            unless foreword.nil? || front.nil?
              foreword.remove
              front << foreword
            end
            unless intro.nil? || front.nil?
              intro.remove
              front << intro
            end
          end

          def termdef_style(xmldoc)
            xmldoc.xpath("//termdef").each do |t|
              para = t.at("./p")
              return if para.nil?
              if para.text =~ /^(the|a)\b/i
                warn "ISO style: #{t.at("term").text}: term definition starts with article"
              end
              if para.text =~ /\.$/i
                warn "ISO style: #{t.at("term").text}: term definition ends with period"
              end
            end
          end

          def termdef_cleanup(xmldoc)
            # release termdef tags from surrounding paras
            nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol |
                             //p/deprecated_term")
            while !nodes.empty?
              nodes[0].parent.replace(nodes[0].parent.children)
              nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol |
                               //p/deprecated_term")
            end
            xmldoc.xpath("//termdef/p/stem").each do |a|
              if a.parent.elements.size == 1
                # para containing just a stem expression
                t = Nokogiri::XML::Element.new("termsymbol", xmldoc)
                parent = a.parent
                a.remove
                t.children = a
                parent.replace(t)
              end
            end
            xmldoc.xpath("//p/termdomain").each do |a|
              prev = a.parent.previous
              a.remove
              prev.next = a
            end
            xmldoc.xpath("//termdef").each do |d|
              t = Nokogiri::XML::Element.new("termdefinition", xmldoc)
              first_child = d.at("./p | ./figure | ./formula")
              first_child.replace(t)
              first_child.remove
              t << first_child
              d.xpath("./p | ./figure | ./formula").each do |n|
                n.remove
                t << n
              end
            end
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

          def table_cleanup(xmldoc)
            # move Key dl after table footer
            xmldoc.xpath("//tfoot/tr/td/dl | //tfoot/tr/th/dl").each do |n|
              if !n.previous_element.nil? && n.previous_element.name == "p" &&
                  n.previous_element.content =~ /^\s*Key\s*$/m
                n.previous_element.remove
                target = n.parent.parent.parent.parent
                n.remove
                target << n
              end
            end
            # move notes after table footer
            xmldoc.xpath("//tfoot/tr/td/note | //tfoot/tr/th/note").each do |n|
              target = n.parent.parent.parent.parent
              n.remove
              target << n
            end
          end

          def formula_cleanup(xmldoc)
            # include where definition list inside stem block
            xmldoc.xpath("//formula").each do |s|
              if !s.next_element.nil? && s.next_element.name == "p" &&
                  s.next_element.content == "where" &&
                  !s.next_element.next_element.nil? &&
                  s.next_element.next_element.name == "dl"
                dl = s.next_element.next_element.remove
                s.next_element.remove
                s << dl
              end
            end
          end

          def figure_cleanup(xmldoc)
            # include key definition list inside figure
            xmldoc.xpath("//figure").each do |s|
              if !s.next_element.nil? && s.next_element.name == "p" &&
                  s.next_element.content =~ /^\s*Key\s*$/m &&
                  !s.next_element.next_element.nil? &&
                  s.next_element.next_element.name == "dl"
                dl = s.next_element.next_element.remove
                s.next_element.remove
                s << dl
              end
            end

            # examples containing only figures become subfigures of figures
            nodes = xmldoc.xpath("//example/figure")
            while !nodes.empty?
              nodes[0].parent.name = "figure"
              nodes = xmldoc.xpath("//example/figure")
            end
          end

          def back_cleanup(xmldoc)
            # move annex/bibliography to back
            if !xmldoc.xpath("//annex | //bibliography").empty?
              b = Nokogiri::XML::Element.new("back", xmldoc)
              xmldoc.root << b
              xmldoc.xpath("//annex").each do |e|
                e.remove
                b << e
              end
              xmldoc.xpath("//bibliography").each do |e|
                e.remove
                b << e
              end
            end
          end

          def ref_cleanup(xmldoc)
            # move ref before p
            xmldoc.xpath("//p/ref").each do |r|
              parent = r.parent
              r.remove
              parent.previous = r
            end

            xmldoc
          end
        end
      end
    end
  end
end
