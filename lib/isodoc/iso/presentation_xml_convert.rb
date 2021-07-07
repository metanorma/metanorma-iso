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

      def eref_localities1_zh(target, type, from, upto, node, delim)
        subsection = from&.text&.match(/\./)
        ret = if delim == ";"
                ";"
              else
                type == "list" ? "" : delim
              end
        ret += " 第#{from.text}" if from
        ret += "&ndash;#{upto.text}" if upto
        loc = (@i18n.locality[type] || type.sub(/^locality:/, "").capitalize)
        ret += " #{loc}" unless subsection && type == "clause" ||
          type == "list" || target.match(/^IEV$|^IEC 60050-/) ||
          node["droploc"] == "true"
        ret += ")" if type == "list"
        ret
      end

      def eref_localities1(target, type, from, upto, delim, node, lang = "en")
        return "" if type == "anchor"

        subsection = from&.text&.match(/\./)
        type = type.downcase
        lang == "zh" and
          return l10n(eref_localities1_zh(target, type, from, upto, node, delim))
        ret = if delim == ";" then ";"
              else
                type == "list" ? "" : delim
              end
        ret += eref_locality_populate(type, node) unless subsection &&
          type == "clause" || type == "list" ||
          target.match(/^IEV$|^IEC 60050-/)
        ret += " #{from.text}" if from
        ret += "&ndash;#{upto.text}" if upto
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

      def concept1(node)
        node&.at(ns("./refterm"))&.remove
        node&.at(ns("./renderterm"))&.name = "em"
        if r = node.at(ns("./xref | ./eref | ./termref"))
          r.name == "termref" and
            r.replace(@i18n.term_defined_in.sub(/%/, r.to_xml)) or
            r.replace("(#{r.to_xml})")
        end
        node.replace(node.children)
      end

      include Init
    end
  end
end
