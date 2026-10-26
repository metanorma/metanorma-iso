require_relative "init"
require "isodoc"
require_relative "presentation_xref"
require_relative "presentation_bibdata"
require_relative "../../metanorma/iso/citation_style"

module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def concept(docxml)
        concept_term(docxml)
        (docxml.xpath(ns("//concept")) - docxml.xpath(ns("//term//concept")))
          .each do |node|
          in_concept_container?(node) and
            concept_render(node, ital: "false", ref: "false",
                                 linkref: "true", linkmention: "false")
        end
      end

      def concept_term(docxml)
        docxml.xpath(ns("//term")).each do |f|
          m = {}
          (f.xpath(ns(".//concept")) - f.xpath(ns(".//term//concept")))
            .each do |c|
              in_concept_container?(c) and
                concept_term1(c, m)
            end
        end
      end

      # Node#ancestors(selector) runs an XPath match per ancestor; with
      # this called per concept on deeply nested terms it is quadratic on
      # large vocabularies. Walk parents directly instead.
      def in_concept_container?(node)
        parent = node.parent
        while parent.is_a?(Nokogiri::XML::Element)
          return true if %w[definition source related].include?(parent.name)

          parent = parent.parent
        end
        false
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
