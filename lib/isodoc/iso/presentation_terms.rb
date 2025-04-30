require_relative "init"
require "isodoc"
require_relative "presentation_xref"
require_relative "presentation_bibdata"
require_relative "../../relaton/render/general"

module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def concept(docxml)
        concept_term(docxml)
        (docxml.xpath(ns("//concept")) - docxml.xpath(ns("//term//concept")))
          .each do |node|
          node.ancestors("definition, source, related").empty? and
            concept_render(node, ital: "false", ref: "false",
                                 linkref: "true", linkmention: "false")
        end
      end

      def concept_term(docxml)
        docxml.xpath(ns("//term")).each do |f|
          m = {}
          (f.xpath(ns(".//concept")) - f.xpath(ns(".//term//concept")))
            .each do |c|
              c.ancestors("definition, source, related").empty? and
                concept_term1(c, m)
            end
        end
      end

      def concept_term1(node, seen)
        term = to_xml(node.at(ns("./refterm")))
        if term && seen[term]
          concept_render(node, ital: "false", ref: "false",
                               linkref: "true", linkmention: "false")
        else concept_render(node, ital: "true", ref: "true",
                                  linkref: "true", linkmention: "false")
        end
        seen[term] = true if term
        seen
      end

      def concept1_ref_content(ref)
        prev = "("
        foll = ")"
        if ref.name == "termref"
          prev, foll = @i18n.term_defined_in.split("%")
        end
        ref.previous = prev
        ref.next = foll
      end

      def concept1(node)
        node.replace(node&.at(ns("./renderterm"))&.children ||
                     node&.at(ns("./refterm"))&.children ||
                     node.children)
      end

      def insertall_after_here(node, insert, name)
        node.children.each do |n|
          n.name == name or next
          insert.next = n.remove
          insert = n
        end
        insert
      end

      def termexamples_before_termnotes(node)
        insert = node.at(ns("./definition")) or return
        insert = insertall_after_here(node, insert, "termexample")
        insertall_after_here(node, insert, "termnote")
      end

      def terms(docxml)
        docxml.xpath(ns("//term[termnote][termexample]")).each do |node|
          termexamples_before_termnotes(node)
        end
        super
      end

      def related1(node)
        node.remove
      end

      def termsource_status(status)
        case status
        when "modified", "adapted"
          @i18n.modified
        end
      end
    end
  end
end
