require_relative "init"
require "isodoc"
require_relative "index"
require_relative "presentation_inline"
require_relative "presentation_xref"
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
        prefix_name(node, "&#xa0;&#x2014; ", lbl, "name")
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
        docxml.xpath(ns("//clause[not(ancestor::annex)] | "\
                        "//terms | //definitions | //references | "\
                        "//preface/introduction[clause]")).each do |f|
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
        term = node&.at(ns("./refterm"))&.to_xml
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
                 @i18n.term_defined_in.sub(/%/, ref.to_xml)
               else "(#{ref.to_xml})"
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
                                "//sections/clause[not(@type = 'scope')] | "\
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
          "&#x3c;#{d.remove.children.to_xml}&#x3e; "
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

        p.children.first.previous = admonition_name(n.remove.children.to_xml)
      end

      def admonition_name(xml)
        "#{xml} &#x2014; "
      end

      def bibrenderer
        ::Relaton::Render::Iso::General.new(language: @lang,
                                            i18nhash: @i18n.get)
      end

      def bibrender(xml)
        unless xml.at(ns("./formattedref"))
          xml.children =
            "#{bibrenderer.render(xml.to_xml)}"\
            "#{xml.xpath(ns('./docidentifier | ./uri | ./note')).to_xml}"
        end
      end

      def bibdata_i18n(bib)
        hash_translate(bib, @i18n.get["doctype_dict"], "./ext/doctype")
        bibdata_i18n_stage(bib, bib.at(ns("./status/stage")),
                           bib.at(ns("./ext/doctype")))
        hash_translate(bib, @i18n.get["substage_dict"], "./status/substage")
        edition_translate(bib)
      end

      def bibdata_i18n_stage(bib, stage, type, lang: @lang, i18n: @i18n)
        return unless stage

        i18n.get["stage_dict"][stage.text].is_a?(Hash) or
          return hash_translate(bib, i18n.get["stage_dict"],
                                "./status/stage", lang)
        i18n.get["stage_dict"][stage.text][type&.text] and
          tag_translate(stage, lang,
                        i18n.get["stage_dict"][stage.text][type&.text])
      end

      include Init
    end
  end
end
