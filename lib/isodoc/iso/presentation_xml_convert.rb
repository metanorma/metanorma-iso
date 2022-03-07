require_relative "init"
require "isodoc"
require_relative "index"

module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def convert1(docxml, filename, dir)
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

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
      end

      def figure1(node)
        return if labelled_ancestor(node) && node.ancestors("figure").empty?

        lbl = @xrefs.anchor(node["id"], :label, false) or return
        figname = node.parent.name == "figure" ? "" : "#{@i18n.figure} "
        connective = node.parent.name == "figure" ? "&nbsp; " : "&nbsp;&mdash; "
        prefix_name(node, connective, l10n("#{figname}#{lbl}"), "name")
      end

      def example1(node)
        n = @xrefs.get[node["id"]]
        lbl = if n.nil? || n[:label].nil? || n[:label].empty?
                @i18n.example
              else
                l10n("#{@i18n.example} #{n[:label]}")
              end
        prefix_name(node, "&nbsp;&mdash; ", lbl, "name")
      end

      def eref_delim(delim, type)
        if delim == ";" then ";"
        else type == "list" ? " " : delim
        end
      end

      def can_conflate_eref_rendering?(refs)
        super or return false

        first = subclause?(nil, refs.first.at(ns("./locality/@type"))&.text,
                           refs.first.at(ns("./locality/referenceFrom"))&.text)
        refs.all? do |r|
          subclause?(nil, r.at(ns("./locality/@type"))&.text,
                     r.at(ns("./locality/referenceFrom"))&.text) == first
        end
      end

      def locality_delimiter(loc)
        loc&.next_element&.attribute("type")&.text == "list" and return " "
        super
      end

      def eref_localities_conflated(refs, target, node)
        droploc = node["droploc"]
        node["droploc"] = true
        ret = resolve_eref_connectives(eref_locality_stacks(refs, target,
                                                            node))
        node["droploc"] = droploc
        eref_localities1(target,
                         prefix_clause(target, refs.first.at(ns("./locality"))),
                         l10n(ret[1..-1].join), nil, node, @lang)
      end

      def prefix_clause(target, loc)
        loc["type"] == "clause" or return loc["type"]

        if subclause?(target, loc["type"], loc&.at(ns("./referenceFrom"))&.text)
          ""
        else
          "clause"
        end
      end

      def subclause?(target, type, from)
        (from&.match?(/\./) && type == "clause") ||
          type == "list" || target&.match(/^IEV$|^IEC 60050-/)
      end

      def eref_localities1_zh(target, type, from, upto, node)
        ret = " 第#{from}" if from
        ret += "&ndash;#{upto}" if upto
        if node["droploc"] != "true" && !subclause?(target, type, from)
          ret += eref_locality_populate(type, node)
        end
        ret += ")" if type == "list"
        ret
      end

      def eref_localities1(target, type, from, upto, node, lang = "en")
        return nil if type == "anchor"

        type = type.downcase
        lang == "zh" and
          return l10n(eref_localities1_zh(target, type, from, upto, node))
        ret = if node["droploc"] != "true" && !subclause?(target, type, from)
                eref_locality_populate(type, node)
              else ""
              end
        ret += " #{from}" if from
        ret += "&ndash;#{upto}" if upto
        ret += ")" if type == "list"
        l10n(ret)
      end

      def prefix_container(container, linkend, target)
        delim = @xrefs.anchor(target, :type) == "listitem" ? " " : ", "
        l10n(@xrefs.anchor(container, :xref) + delim + linkend)
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
                        "//preface/introduction[clause]"))
          .each do |f|
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
          f.xpath(ns(".//concept")).each do |c|
            concept_term1(c, m)
          end
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
        if ref.name == "termref"
          ref.replace(@i18n.term_defined_in.sub(/%/,
                                                ref.to_xml))
        else
          ref.replace("(#{ref.to_xml})")
        end
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

      include Init
    end
  end
end
