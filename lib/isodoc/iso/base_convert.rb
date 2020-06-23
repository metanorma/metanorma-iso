require "isodoc"
require_relative "metadata"
require_relative "sections"
require_relative "xref"
require "fileutils"

module IsoDoc
  module Iso
    module BaseConvert
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
      end

      def amd(docxml)
        doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        %w(amendment technical-corrigendum).include? doctype
      end

      def convert1(docxml, filename, dir)
        if amd(docxml)
          @oldsuppressheadingnumbers = @suppressheadingnumbers
          @suppressheadingnumbers = true
        end
        super
      end

      def implicit_reference(b)
        b&.at(ns("./docidentifier"))&.text == "IEV"
      end

      # terms not defined in standoc
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def eref_localities1_zh(target, type, from, to, delim)
        subsection = from&.text&.match(/\./)
        ret = (delim == ";") ? ";" : (type == "list") ? "" : delim
        ret += " 第#{from.text}" if from
        ret += "&ndash;#{to}" if to
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
        return l10n(eref_localities1_zh(target, type, from, to, delim)) if lang == "zh"
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
        n = @xrefs.get[node["id"]]
        div.span **{ class: "example_label" } do |p|
          lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
            l10n("#{@example_lbl} #{n[:label]}")
          p << lbl
          name and !lbl.nil? and p << "&nbsp;&mdash; "
          name and name.children.each { |n| parse(n, div) }
        end
      end

      def example_p_parse(node, div)
        name = node&.at(ns("./name"))&.remove
        div.p do |p|
          example_span_label(node, p, name)
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def example_parse1(node, div)
        div.p do |p|
          example_span_label(node, p, node.at(ns("./name")))
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) unless n.name == "name" }
      end

      def node_begins_with_para(node)
        node.elements.each do |e|
          next if e.name == "name"
          return true if e.name == "p"
          return false
        end
        false
      end

      def example_parse(node, out)
        out.div **{ id: node["id"], class: "example" } do |div|
          if node_begins_with_para(node)
            example_p_parse(node, div)
          else
            example_parse1(node, div)
          end
        end
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
        return unless node.at(ns("./termnote")) && node.at(ns("./termexample"))
        return unless insert = node.at(ns("./definition"))
        insert = insertall_after_here(node, insert, "termexample")
        insert = insertall_after_here(node, insert, "termnote")
      end

      def termdef_parse(node, out)
        termexamples_before_termnotes(node)
        super
      end

      def clausedelim
        ""
      end

      def cleanup(docxml)
        super
        table_th_center(docxml)
        docxml
      end

      def table_th_center(docxml)
        docxml.xpath("//thead//th | //thead//td").each do |th|
          th["align"] = "center"
          th["valign"] = "middle"
        end
      end

      def formula_where(dl, out)
        return if dl.nil?
        return super unless (dl&.xpath(ns("./dt"))&.size == 1 && 
                             dl&.at(ns("./dd"))&.elements&.size == 1 &&
                             dl&.at(ns("./dd/p")))
        out.span **{ class: "zzMoveToFollowing" } do |s|
          s << "#{@where_lbl} "
          dl.at(ns("./dt")).children.each { |n| parse(n, s) }
          s << " "
        end
        parse(dl.at(ns("./dd/p")), out)
      end

      def admonition_parse(node, out)
        type = node["type"]
        name = admonition_name(node, type)
        out.div **{ id: node["id"], class: admonition_class(node) } do |div|
          node.first_element_child.name == "p" ?
            admonition_p_parse(node, div, name) : admonition_parse1(node, div, name)
        end
      end

      def admonition_parse1(node, div, name)
        div.p do |p|
          admonition_name_parse(node, p, name) if name
        end
        node.children.each { |n| parse(n, div) unless n.name == "name" }
      end

      def admonition_p_parse(node, div, name)
        div.p do |p|
          admonition_name_parse(node, p, name) if name
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def admonition_name_parse(_node, div, name)
        name.children.each { |n| parse(n, div) }
        div << " &mdash; "
      end

      def figure_name_parse(node, div, name)
        lbl = @xrefs.anchor(node['id'], :label, false)
        lbl = nil if labelled_ancestor(node) && node.ancestors("figure").empty?
        return if lbl.nil? && name.nil?
        div.p **{ class: "FigureTitle", style: "text-align:center;" } do |p|
          figname = node.parent.name == "figure" ? "" : "#{@figure_lbl} "
          lbl.nil? or p << l10n("#{figname}#{lbl}")
          name and !lbl.nil? and p << "&nbsp;&mdash; "
          name and name.children.each { |n| parse(n, div) }
        end
      end
    end
  end
end
