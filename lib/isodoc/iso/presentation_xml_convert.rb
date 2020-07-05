require_relative "init"
require "isodoc"

module IsoDoc
  module Iso

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        super
      end

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

      def figure1(f)
        return if labelled_ancestor(f) && f.ancestors("figure").empty?
        lbl = @xrefs.anchor(f['id'], :label, false) or return
        figname = f.parent.name == "figure" ? "" : "#{@figure_lbl} "
        prefix_name(f, "&nbsp;&mdash; ", l10n("#{figname}#{lbl}"), "name")
      end

      def example1(f)
        n = @xrefs.get[f["id"]]
        lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
          l10n("#{@example_lbl} #{n[:label]}")
        prefix_name(f, "&nbsp;&mdash; ", lbl, "name")
      end

      def eref_localities1_zh(target, type, from, to, delim)
        subsection = from&.text&.match(/\./)
        ret = (delim == ";") ? ";" : (type == "list") ? "" : delim
        ret += " 第#{from.text}" if from
        ret += "&ndash;#{to.text}" if to
        loc = (@locality[type] || type.sub(/^locality:/, "").capitalize )
        ret += " #{loc}" unless subsection && type == "clause" ||
          type == "list" || target.match(/^IEV$|^IEC 60050-/)
        ret += ")" if type == "list"
        ret
      end

      def eref_localities1(target, type, from, to, delim, lang = "en")
        return "" if type == "anchor"
        subsection = from&.text&.match(/\./)
        type = type.downcase
        lang == "zh" and
          return l10n(eref_localities1_zh(target, type, from, to, delim))
        ret = (delim == ";") ? ";" : (type == "list") ? "" : delim
        loc = @locality[type] || type.sub(/^locality:/, "").capitalize
        ret += " #{loc}" unless subsection && type == "clause" ||
          type == "list" || target.match(/^IEV$|^IEC 60050-/)
        ret += " #{from.text}" if from
        ret += "&ndash;#{to.text}" if to
        ret += ")" if type == "list"
        l10n(ret)
      end

      def prefix_container(container, linkend, target)
        delim = @xrefs.anchor(target, :type) == "listitem" ? " " : ", "
        l10n(@xrefs.anchor(container, :xref) + delim + linkend)
      end

      def example_span_label(node, div, name)
        return if name.nil?
        div.span **{ class: "example_label" } do |p|
          name.children.each { |n| parse(n, div) }
        end
      end

      def clause1(f)
        if !f.at(ns("./title")) &&
            !%w(sections preface bibliography).include?(f.parent.name)
          f["inline-header"] = "true"
        end
        super
      end

      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::boilerplate)]"\
                        "[not(ancestor::annex)] | "\
                        "//terms | //definitions | //references | "\
                        "//preface/introduction[clause]")).
        each do |f|
          clause1(f)
        end
      end

      include Init
    end
  end
end
