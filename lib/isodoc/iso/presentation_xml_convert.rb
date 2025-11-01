require_relative "init"
require "isodoc"
require_relative "presentation_xref"
require_relative "presentation_bibdata"
require_relative "presentation_section"
require_relative "presentation_terms"
require_relative "../../relaton/render/general"

module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def convert_i18n_init(docxml)
        super
        update_i18n(docxml)
      end

      def convert1(docxml, filename, dir)
        @iso_class = instance_of?(IsoDoc::Iso::PresentationXMLConvert)
        if amd?(docxml)
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
        source docxml
        ul docxml
        ol docxml
        quote docxml
        permission docxml
        requirement docxml
        recommendation docxml
        requirement_render docxml
        @xrefs.anchors_previous = 
          @xrefs.anchors.transform_values(&:dup) # store old xrefs of reqts
        @xrefs.parse docxml
        # TODO move this dependency around: requirements at root should be processed before everything else
        table docxml # have table include requirements newly converted to tables
        # table feeds dl
        dl docxml
        example docxml
        note docxml
      end

      def subfigure_delim
        "<span class='fmt-label-delim'>)</span>"
      end

      def figure_delim(elem)
        elem.at("./ancestor::xmlns:figure") ? "&#xa0; " : "&#xa0;&#x2014; "
      end

      def figure_name(elem)
        elem.at("./ancestor::xmlns:figure") and return ""
        super
      end

      def figure_label?(_elem)
        true
      end

      def example_span_label(_node, div, name)
        name.nil? and return
        div.span class: "example_label" do |_p|
          name.children.each { |n| parse(n, div) }
        end
      end

      def admonition1(elem)
        super
        admonition_outside_clauses(elem)
      end

      def admonition_outside_clauses(elem)
        elem.parent.name == "sections" or return
        wrap_in_bold(elem)
      end

      def wrap_in_bold(cell)
        cell.text? && cell.text.strip.empty? and return
        cell.text? and cell.swap("<strong>#{cell.to_xml}</strong>")
        %w(strong fn).include?(cell.name) and return
        cell.children.each { |p| wrap_in_bold(p) }
      end

      def bibrender_formattedref(formattedref, xml)
        %w(techreport standard).include? xml["type"] and return
        super
      end

      def ol_depth(node)
        depth = node.ancestors(@iso_class ? "ol" : "ul, ol").size + 1
        @counter.ol_type(node, depth)
      end

      def note1(elem)
        elem["type"] == "units" and return
        elem["type"] == "requirement" and return requirement_note1(elem)
        super
      end

      def requirement_note1(elem)
        elem["unnumbered"] = "true"
      end

      def formula_where(dlist)
        dlist.nil? and return
        dlist.xpath(ns("./dt")).size == 1 &&
          dlist.at(ns("./dd"))&.elements&.size == 1 &&
          dlist.at(ns("./dd/p")) or return super
        formula_where_one(dlist)
      end

      def formula_where_one(dlist)
        dt = to_xml(dlist.at(ns("./dt")).children)
        dd = to_xml(dlist.at(ns("./dd/p")).children)
        dlist.previous = "<p>#{@i18n.where_one} #{dt} #{dd}</p>"
        dlist.remove
      end

      def table1(elem)
        table1_key(elem)
        if elem["class"] == "modspec"
          if n = elem.at(ns(".//fmt-name"))
            n.remove.name = "name"
            elem.add_first_child(n)
          end
          elem.at(ns("./thead"))&.remove
          super
          elem.at(ns("./name"))&.remove
          table1_fmt_xref_modspec(elem)
        else super
        end
      end

      def table1_fmt_xref_modspec(elem)
        p = elem.parent.parent.at(ns("./fmt-xref-label")) or return
        t = elem.at(ns("./fmt-xref-label"))&.remove or return
        n = t.at(ns("./span[@class='fmt-element-name'][2]")) or return
        while i = n.next
          i.remove
        end
        n.remove
        p.children.first.previous = to_xml(t.children)
      end

      def table1_key(elem)
        elem.xpath(ns(".//dl[@key = 'true'][not(./name)]")).each do |dl|
          dl.add_first_child "<name>#{@i18n.key}</name>"
        end
      end

      def labelled_ancestor(elem, exceptions = [])
        elem["class"] == "modspec" and return false
        super
      end

      def twitter_cldr_localiser_symbols
        { group: "&#xA0;", fraction_group: "&#xA0;",
          fraction_group_digits: 3, decimal: "," }
      end

      def implicit_reference(bib)
        bib.at(ns("./docidentifier"))&.text == "IEV" and return true
        super
      end

      def render_identifier(ident)
        ret = super
        ret[:sdo] = std_docid_semantic(ret[:sdo])
        ret
      end

      def admonition_delim(elem)
        if elem.at("./*[not(self::xmlns:name)]")&.name == "p"
          " &#x2014; "
        else
          ""
        end
      end

      def ul_label_list(_elem)
        if @docscheme == "1951"
          %w(&#x2013;)
        else
          %w(&#x2014;)
        end
      end

      def ol_label_template(_elem)
        ret = super
        @docscheme == "1951" and
          ret[:alphabet] = <<~SPAN.strip
            <span class="fmt-label-delim">(</span>%<span class="fmt-label-delim">)</span>
          SPAN
        ret
      end

      def fn_ref_label(fnote)
        if fnote.ancestors("table, figure").empty? ||
            !fnote.ancestors("name, fmt-name").empty?
          "<sup>#{fn_label(fnote)}" \
            "<span class='fmt-label-delim'>)</span></sup>"
        else
          super
        end
      end

      def citeas_cleanup1(citeas)
        ret = super
        if /^\[\d+\]$/.match?(ret)
          ret = @i18n.l10n("#{@i18n.reference} #{ret}")
        end
        ret
      end
      
      include Init
    end
  end
end
