require_relative "init"
require "isodoc"
require_relative "index"
require_relative "presentation_xref"
require_relative "presentation_bibdata"
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
        amd?(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        isoxml.xpath(ns("//annex//clause | //annex//appendix")).each do |f|
          clause1(f)
        end
        amd?(isoxml) and @suppressheadingnumbers = true
      end

      def figure1(node)
        lbl = @xrefs.anchor(node["id"], :label, false) or return
        figname = node.parent.name == "figure" ? "" : "#{@i18n.figure} "
        conn = node.parent.name == "figure" ? "&#xa0; " : "&#xa0;&#x2014; "
        prefix_name(node, conn, l10n("#{figname}#{lbl}"), "name")
      end

      def example1(node)
        n = @xrefs.get[node["id"]]
        lbl = if n.nil? || blank?(n[:label]) then @i18n.example
              else l10n("#{@i18n.example} #{n[:label]}")
              end
        prefix_name(node, block_delim, lbl, "name")
      end

      def example_span_label(_node, div, name)
        name.nil? and return
        div.span class: "example_label" do |_p|
          name.children.each { |n| parse(n, div) }
        end
      end

      def clause1(node)
        if !node.at(ns("./title")) &&
            !%w(sections preface bibliography).include?(node.parent.name)
          node["inline-header"] = "true"
        end
        super
        if node["type"] == "section"
          t = node.at(ns("./title/tab")) and
            t.previous = @i18n.l10n(": ").sub(/\p{Zs}$/, "")
        end
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

      def admonition1(elem)
        super
        admonition_inline_name(elem)
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

      def admonition_inline_name(elem)
        n = elem.at(ns("./name")) or return
        if (p = n.next_element) && p&.name == "p"
          p.children.first.previous = admonition_name(to_xml(n.remove.children))
        end
      end

      def admonition_name(xml)
        "#{xml} &#x2014; "
      end

      def bibrender_formattedref(formattedref, xml)
        %w(techreport standard).include? xml["type"] and return
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

      def note1(elem)
        elem["type"] == "units" and return
        super
      end

      def formula_where(dlist)
        dlist.nil? and return
        return super unless dlist.xpath(ns("./dt")).size == 1 &&
          dlist.at(ns("./dd"))&.elements&.size == 1 &&
          dlist.at(ns("./dd/p"))

        formula_where_one(dlist)
      end

      def formula_where_one(dlist)
        dt = to_xml(dlist.at(ns("./dt")).children)
        dd = to_xml(dlist.at(ns("./dd/p")).children)
        dlist.previous = "<p>#{@i18n.where_one} #{dt} #{dd}</p>"
        dlist.remove
      end

      def table1(elem)
        elem.xpath(ns(".//dl[@key = 'true'][not(./name)]")).each do |dl|
          dl.children.first.previous = "<name>#{@i18n.key}</name>"
        end
        super
      end

      def toc_title(docxml)
        %w(amendment technical-corrigendum).include?(@doctype) and return
        super
      end

      def middle_title(docxml)
        @meta.get[:doctitlemain].nil? || @meta.get[:doctitlemain].empty? and
          return
        s = docxml.at(ns("//sections")) or return
        ret = "#{middle_title_main}#{middle_title_amd}"
        s.children.first.previous = ret
      end

      def middle_title_main
        ret = "<span class='boldtitle'>#{@meta.get[:doctitleintro]}"
        @meta.get[:doctitleintro] && @meta.get[:doctitlemain] and
          ret += " &#x2014; "
        ret += @meta.get[:doctitlemain]
        @meta.get[:doctitlemain] && @meta.get[:doctitlepart] and
          ret += " &#x2014; "
        ret += "</span>#{middle_title_part}"
        "<p class='zzSTDTitle1'>#{ret}</p>"
      end

      def middle_title_part
        ret = ""
        if a = @meta.get[:doctitlepart]
          b = @meta.get[:doctitlepartlabel] and
            ret += "<span class='nonboldtitle'>#{b}:</span> "
          ret += "<span class='boldtitle'>#{a}</span>"
        end
        ret
      end

      def middle_title_amd
        ret = ""
        if a = @meta.get[:doctitleamdlabel]
          ret += "<p class='zzSTDTitle2'>#{a}"
          a = @meta.get[:doctitleamd] and ret += ": #{a}"
          ret += "</p>"
        end
        a = @meta.get[:doctitlecorrlabel] and
          ret += "<p class='zzSTDTitle2'>#{a}</p>"
        ret
      end

      def move_norm_ref_to_sections(docxml)
        if amd?(docxml)
        else super
        end
      end

      def twitter_cldr_localiser_symbols
        { group: "&#xA0;", fraction_group: "&#xA0;",
          fraction_group_digits: 3 }
      end

      include Init
    end
  end
end
