require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module Iso
    module BaseConvert
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def implicit_reference(b)
        b&.at(ns("./docidentifier"))&.text == "IEV"
      end

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction")) || return
        num = f.at(ns(".//clause")) ? "0" : nil
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(num, @introduction_lbl, div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword")) || return
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def initial_anchor_names(d)
        super
        introduction_names(d.at(ns("//introduction")))
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        return if clause.nil?
        clause.xpath(ns("./clause")).each_with_index do |c, i|
          section_names1(c, "0.#{i + 1}", 2)
        end
      end

      # terms not defined in standoc
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        super
      end

      def appendix_names(clause, num)
        clause.xpath(ns("./appendix")).each_with_index do |c, i|
          @anchors[c["id"]] = anchor_struct(i + 1, nil, @appendix_lbl, "clause")
          @anchors[c["id"]][:level] = 2
          @anchors[c["id"]][:container] = clause["id"]
        end
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | ./references")).
          each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { label: num, xref: num, level: level }
        clause.xpath(ns("./clause | ./references")).each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", level + 1)
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
        delim = anchor(target, :type) == "listitem" ? " " : ", "
        l10n(anchor(container, :xref) + delim + linkend)
      end

      def example_span_label(node, div, name)
        n = get_anchors[node["id"]]
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

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref].
                                sub(/ \(All Parts\)/i, "") }
      end

      def table_footnote_reference_format(a)
        a.content = a.content + ")"
      end

      def clause_parse_title(node, div, c1, out)
        return inline_header_title(out, node, c1) if c1.nil?
        super
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

      def hierarchical_formula_names(clause, num)
        c = IsoDoc::Function::XrefGen::Counter.new
        clause.xpath(ns(".//formula")).each do |t|
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] =
            anchor_struct("#{num}#{hiersep}#{c.increment(t).print}", t,
                          t["inequality"] ? @inequality_lbl : @formula_lbl,
                          "formula", t["unnumbered"])
        end
      end
    end
  end
end
