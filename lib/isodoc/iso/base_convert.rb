require "isodoc"
require_relative "sections"
require "fileutils"

module IsoDoc
  module Iso
    module BaseConvert
      def convert1(docxml, filename, dir)
        if amd?(docxml)
          @oldsuppressheadingnumbers = @suppressheadingnumbers
          @suppressheadingnumbers = true
        end
        super
      end

      # terms not defined in standoc
      # KILL
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def example_span_label(_node, div, name)
        name.nil? and return
        div.span class: "example_label" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def example_p_class
        nil
      end

      def example_p_parse(node, div)
        name = node.at(ns("./fmt-name"))
        para = node.at(ns("./p"))
        div.p **attr_code(class: example_p_class) do |p|
          name and p.span class: "example_label" do |s|
            name.children.each { |n| parse(n, s) }
          end
          insert_tab(p, 1) # TODO to Presentation XML
          children_parse(para, p)
        end
        para.xpath("./following-sibling::*").each { |n| parse(n, div) }
      end

      def example_parse1(node, div)
        div.p do |p|
          example_span_label(node, p, node.at(ns("./fmt-name")))
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) unless n.name == "fmt-name" }
      end

      def example_parse(node, out)
        out.div id: node["id"], class: "example" do |div|
          if starts_with_para?(node)
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

      def admonition_class(node)
        if node["type"] == "editorial" then "zzHelp"
        else super
        end
      end

      def admonition_p_parse(node, div)
        admonition_name_in_first_para(node, div)
      end

      # TODO: To Presentation XML
      def admonition_name_para_delim(para)
        para << " "
      end

      def figure_name_parse(_node, div, name)
        name.nil? and return
        div.p class: "FigureTitle", style: "text-align:center;" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def top_element_render(elem, out)
        if %w(clause terms definitions).include?(elem.name) &&
            elem.parent.name == "sections" &&
            elem["type"] != "scope"
          clause_etc1(elem, out, 0)
        else super
        end
      end

      def clause_etc1(clause, out, num)
        out.div **attr_code(
          id: clause["id"],
          class: clause.name == "definitions" ? "Symbols" : nil,
        ) do |div|
          num = num + 1
          clause_name(clause, clause&.at(ns("./fmt-title")), div, nil)
          clause.elements.each do |e|
            parse(e, div) unless %w{fmt-title source}.include? e.name
          end
        end
      end

      def ol_attrs(node)
        super.merge(start: node["start"]).compact
      end

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        measurement_units(node, out)
        out.table **table_attrs(node) do |t|
          table_parse_core(node, t)
          table_parse_tail(node, t)
        end
        @in_table = false
      end

      def table_parse_tail(node, out)
        (dl = node.at(ns("./dl"))) && parse(dl, out)
        node.xpath(ns("./source")).each { |n| parse(n, out) }
        node.xpath(ns("./note[not(@type = 'units')]")).each do |n|
          parse(n, out)
        end
        node.xpath(ns("./fmt-footnote-container/fmt-fn-body"))
          .each { |n| parse(n, out) }
      end

      def figure_parse1(node, out)
        measurement_units(node, out)
        out.div **figure_attrs(node) do |div|
          node.children.each do |n|
            n.name == "note" && n["type"] == "units" and next
            parse(n, div) unless n.name == "fmt-name"
          end
          figure_name_parse(node, div, node.at(ns("./fmt-name")))
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

      def table_cleanup(docxml)
        super
        docxml.xpath("//tfoot/div[@class = 'figdl']/p[@class = 'ListTitle']")
          .each do |p|
          p["align"] = "left"
        end
        docxml
      end

      def convert_i18n_init(docxml)
        super
        update_i18n(docxml)
      end

      def span_parse(node, out)
        node["class"] == "fmt-obligation" and
          node["class"] = "obligation"
        super
      end
    end
  end
end
