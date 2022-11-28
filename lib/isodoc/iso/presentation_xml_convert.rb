require_relative "init"
require "isodoc"
require_relative "index"
require_relative "presentation_xref"
require_relative "presentation_bibdata"
require_relative "../../relaton/render/general"

module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def convert1(docxml, filename, dir)
        @iso_class = instance_of?(IsoDoc::Iso::PresentationXMLConvert)
        if amd(docxml)
          @oldsuppressheadingnumbers = @suppressheadingnumbers
          @suppressheadingnumbers = true
        end
        super
      end

      def block(docxml)
        amend docxml
        figure docxml
        sourcecode docxml
        formula docxml
        admonition docxml
        ol docxml
        permission docxml
        requirement docxml
        recommendation docxml
        requirement_render docxml
        @xrefs.anchors_previous = @xrefs.anchors.dup # store old xrefs of reqts
        @xrefs.parse docxml
        table docxml # have table include requirements newly converted to tables
        example docxml
        note docxml
      end

      def annex(isoxml)
        amd(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        isoxml.xpath(ns("//annex//clause | //annex//appendix")).each do |f|
          clause1(f)
        end
        amd(isoxml) and @suppressheadingnumbers = true
      end

      def figure1(node)
        lbl = @xrefs.anchor(node["id"], :label, false) or return
        figname = node.parent.name == "figure" ? "" : "#{@i18n.figure} "
        connective = node.parent.name == "figure" ? "&#xa0; " : "&#xa0;&#x2014; "
        prefix_name(node, connective, l10n("#{figname}#{lbl}"), "name")
      end

      def example1(node)
        n = @xrefs.get[node["id"]]
        lbl = if n.nil? || blank?(n[:label]) then @i18n.example
              else l10n("#{@i18n.example} #{n[:label]}")
              end
        prefix_name(node, block_delim, lbl, "name")
      end

      def example_span_label(_node, div, name)
        return if name.nil?

        div.span **{ class: "example_label" } do |_p|
          name.children.each { |n| parse(n, div) }
        end
      end

      def clause1(node)
        if !node.at(ns("./title")) &&
            !%w(sections preface bibliography).include?(node.parent.name)
          node["inline-header"] = "true"
        end
        super
      end

      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::annex)] | " \
                        "//terms | //definitions | //references | " \
                        "//preface/introduction[clause]")).each do |f|
          f.parent.name == "annex" &&
            @xrefs.klass.single_term_clause?(f.parent) and next
          clause1(f)
        end
      end

      def concept(docxml)
        concept_term(docxml)
        docxml.xpath(ns("//concept")).each do |node|
          concept_render(node, ital: "false", ref: "false",
                               linkref: "true", linkmention: "false")
        end
      end

      def concept_term(docxml)
        docxml.xpath(ns("//term")).each do |f|
          m = {}
          f.xpath(ns(".//concept")).each { |c| concept_term1(c, m) }
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
        repl = if ref.name == "termref"
                 @i18n.term_defined_in.sub(/%/, to_xml(ref))
               else "(#{to_xml(ref)})"
               end
        ref.replace(repl)
      end

      def concept1(node)
        node.replace(node&.at(ns("./renderterm"))&.children ||
                     node&.at(ns("./refterm"))&.children ||
                     node.children)
      end

      # we're assuming terms and clauses in the right place for display,
      # to cope with multiple terms sections

      def display_order(docxml)
        i = 0
        i = display_order_xpath(docxml, "//preface/*", i)
        i = display_order_at(docxml, "//clause[@type = 'scope']", i)
        i = display_order_at(docxml, @xrefs.klass.norm_ref_xpath, i)
        i = display_order_xpath(docxml,
                                "//sections/clause[not(@type = 'scope')] | " \
                                "//sections/terms | //sections/definitions", i)
        i = display_order_xpath(docxml, "//annex", i)
        i = display_order_xpath(docxml, @xrefs.klass.bibliography_xpath, i)
        display_order_xpath(docxml, "//indexsect", i)
      end

      def termdefinition1(elem)
        prefix_domain_to_definition(elem)
        super
      end

      def prefix_domain_to_definition(elem)
        ((d = elem.at(ns("./domain"))) &&
          (v = elem.at(ns("./definition/verbal-definition"))) &&
          v.elements.first.name == "p") or return
        v.elements.first.children.first.previous =
          "&#x3c;#{to_xml(d.remove.children)}&#x3e; "
      end

      def insertall_after_here(node, insert, name)
        node.children.each do |n|
          next unless n.name == name

          insert.next = n.remove
          insert = n
        end
        insert
      end

      def termexamples_before_termnotes(node)
        return unless insert = node.at(ns("./definition"))

        insert = insertall_after_here(node, insert, "termexample")
        insertall_after_here(node, insert, "termnote")
      end

      def terms(docxml)
        docxml.xpath(ns("//term[termnote][termexample]")).each do |node|
          termexamples_before_termnotes(node)
        end
        super
      end

      def admonition1(elem)
        super
        return unless n = elem.at(ns("./name"))

        p = n.next_element
        return unless p.name == "p"

        p.children.first.previous = admonition_name(to_xml(n.remove.children))
      end

      def admonition_name(xml)
        "#{xml} &#x2014; "
      end

      def bibrenderer
        ::Relaton::Render::Iso::General.new(language: @lang,
                                            i18nhash: @i18n.get)
      end

      def bibrender_formattedref(formattedref, xml)
        return if %w(techreport standard).include? xml["type"]

        super
      end

      def ol_depth(node)
        depth = node.ancestors(@iso_class ? "ol" : "ul, ol").size + 1
        type = :alphabet
        type = :arabic if [2, 7].include? depth
        type = :roman if [3, 8].include? depth
        type = :alphabet_upper if [4, 9].include? depth
        type = :roman_upper if [5, 10].include? depth
        type
      end

      def related1(node)
        node.remove
      end

      include Init
    end
  end
end
