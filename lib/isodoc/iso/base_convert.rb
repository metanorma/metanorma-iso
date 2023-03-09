require "isodoc"
require_relative "sections"
require "fileutils"

module IsoDoc
  module Iso
    module BaseConvert
      def convert1(docxml, filename, dir)
        if amd(docxml)
          @oldsuppressheadingnumbers = @suppressheadingnumbers
          @suppressheadingnumbers = true
        end
        super
      end

      def implicit_reference(bib)
        return true if bib&.at(ns("./docidentifier"))&.text == "IEV"

        super
      end

      # terms not defined in standoc
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def example_span_label(_node, div, name)
        return if name.nil?

        div.span class: "example_label" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def example_p_parse(node, div)
        div.p do |p|
          example_span_label(node, p, node&.at(ns("./name"))&.remove)
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
        out.div id: node["id"], class: "example" do |div|
          if node_begins_with_para(node)
            example_p_parse(node, div)
          else
            example_parse1(node, div)
          end
        end
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

      def admonition_parse(node, out)
        type = node["type"]
        name = admonition_name(node, type)
        out.div id: node["id"], class: admonition_class(node) do |div|
          if node.first_element_child.name == "p"
            admonition_p_parse(node, div, name)
          else
            admonition_parse1(node, div, name)
          end
        end
      end

      def admonition_class(node)
        if node["type"] == "editorial" then "zzHelp"
        else super
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
        div << " &#x2014; "
      end

      def figure_name_parse(_node, div, name)
        div.p class: "FigureTitle", style: "text-align:center;" do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def middle(isoxml, out)
        middle_title(isoxml, out)
        middle_admonitions(isoxml, out)
        i = scope isoxml, out, 0
        i = norm_ref isoxml, out, i
        clause_etc isoxml, out, i
        annex isoxml, out
        bibliography isoxml, out
      end

      def clause_etc(isoxml, out, num)
        isoxml.xpath(ns("//sections/clause[not(@type = 'scope')] | " \
                        "//sections/terms | //sections/definitions"))
          .each do |f|
            clause_etc1(f, out, num)
          end
      end

      def clause_etc1(clause, out, num)
        out.div **attr_code(
          id: clause["id"],
          class: clause.name == "definitions" ? "Symbols" : nil,
        ) do |div|
          num = num + 1
          clause_name(clause, clause&.at(ns("./title")), div, nil)
          clause.elements.each do |e|
            parse(e, div) unless %w{title source}.include? e.name
          end
        end
      end

      def indexsect(isoxml, out)
        isoxml.xpath(ns("//indexsect")).each do |i|
          clause_parse(i, out)
        end
      end

      def ol_attrs(node)
        super.merge(start: node["start"]).compact
      end

      def render_identifier(ident)
        ret = super
        ret[:sdo] = std_docid_semantic(ret[:sdo])
        ret
      end

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        measurement_units(node, out)
        out.table **table_attrs(node) do |t|
          table_parse_core(node, t)
          (dl = node.at(ns("./dl"))) && parse(dl, out)
          node.xpath(ns("./note[not(@type = 'units')]"))
            .each { |n| parse(n, out) }
        end
        @in_table = false
      end

      def figure_parse1(node, out)
        measurement_units(node, out)
        out.div **figure_attrs(node) do |div|
          node.children.each do |n|
            figure_key(out) if n.name == "dl"
            next if n.name == "note" && n["type"] == "units"

            parse(n, div) unless n.name == "name"
          end
          figure_name_parse(node, div, node.at(ns("./name")))
        end
      end

      def measurement_units(node, out)
        node.xpath(ns("./note[@type = 'units']")).each do |n|
          out.div align: "right" do |p|
            p.b do |b|
              n.children.each { |e| parse(e, b) }
            end
          end
        end
      end
    end
  end
end
