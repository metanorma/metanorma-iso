require_relative "init"
require "isodoc"
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

      def section(docxml)
        super
        warning_for_missing_metadata(docxml)
      end

      def warning_for_missing_metadata(docxml)
        @meta.get[:unpublished] or return
        ret = warning_for_missing_metadata_create(docxml)
        ret.empty? and return
        warning_for_missing_metadata_post(docxml, ret)
      end

      def warning_for_missing_metadata_create(docxml)
        ret = ""
        docxml.at(ns("//bibdata/ext//secretariat")) or
          ret += "<p>Secretariat is missing.</p>"
        docxml.at(ns("//bibdata/ext//editorialgroup")) or
          ret += "<p>Editorial groups are missing.</p>"
        docxml.at(ns("//bibdata/date[@type = 'published' or @type = 'issued' " \
                     "or @type = 'created']")) ||
          docxml.at(ns("//bibdata/version/revision-date")) or
          ret += "<p>Document date is missing.</p>"
        ret
      end

      def warning_for_missing_metadata_post(docxml, ret)
        id = UUIDTools::UUID.random_create
        ret = "<review date='#{Date.today}' reviewer='Metanorma' id='_#{id}'>" \
              "<p><strong>Metadata warnings:<strong></p> #{ret}</review>"
        ins = docxml.at(ns("//sections//fmt-title")) or return
        ins.add_first_child ret
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
        @xrefs.anchors_previous = @xrefs.anchors.dup # store old xrefs of reqts
        @xrefs.parse docxml
        # TODO move this dependency around: requirements at root should be processed before everything else
        table docxml # have table include requirements newly converted to tables
        # table feeds dl
        dl docxml
        example docxml
        note docxml
      end

      # Redo Amendment annex titles as numbered
      def annex(isoxml)
        amd?(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        amd?(isoxml) and @suppressheadingnumbers = true
      end

      # Redo Amendment annex subclause titles as numbered
      def clause(docxml)
        super
        docxml.xpath(ns("//annex//appendix")).each { |f| clause1(f) }
        amd?(docxml) or return
        @suppressheadingnumbers = @oldsuppressheadingnumbers
        docxml.xpath(ns("//annex//clause | //annex//appendix")).each do |f|
          f.xpath(ns("./fmt-title | ./fmt-xref-label")).each(&:remove)
          clause1(f)
        end
        @suppressheadingnumbers = true
      end

      def subfigure_delim
        "<span class='fmt-label-delim'>)</span>"
      end

      def figure_delim(elem)
        elem.parent.name == "figure" ? "&#xa0; " : "&#xa0;&#x2014; "
      end

      def figure_name(elem)
        elem.parent.name == "figure" and return ""
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

      def clause1(node)
        !node.at(ns("./title")) &&
          !%w(sections preface bibliography).include?(node.parent.name) and
          node["inline-header"] = "true"
        super
        clause1_section_prefix(node)
      end

      def clause1_section_prefix(node)
        if node["type"] == "section" &&
            c = node.at(ns("./fmt-title//span[@class = 'fmt-caption-delim']"))
          c.add_first_child(":")
          t = node.at(ns("./fmt-title"))
          # French l10n needs tab to be treated as space
          t.replace @i18n.l10n(to_xml(t).gsub("<tab/>", "<tab> </tab>"))
            .gsub(%r{<tab>[^<]+</tab>}, "<tab/>")
        end
      end

      #       def clause(docxml)
      #         docxml.xpath(ns("//clause[not(ancestor::annex)] | " \
      #                         "//terms | //definitions | //references | " \
      #                         "//preface/introduction[clause]")).each do |f|
      #           f.parent.name == "annex" &&
      #             @xrefs.klass.single_term_clause?(f.parent) and next
      #           clause1(f)
      #         end
      #       end

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
          n = elem.at(ns(".//fmt-name")).remove
          n.name = "name"
          elem.add_first_child(n)
          elem.at(ns("./thead"))&.remove
          super
          elem.at(ns("./name")).remove
        else super
        end
      end

      def table1_key(elem)
        elem.xpath(ns(".//dl[@key = 'true'][not(./name)]")).each do |dl|
          dl.add_first_child "<name>#{@i18n.key}</name>"
        end
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
        s.add_first_child ret
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
        amd?(docxml) or super
      end

      def twitter_cldr_localiser_symbols
        { group: "&#xA0;", fraction_group: "&#xA0;",
          fraction_group_digits: 3 }
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

      def enable_indexsect
        true
      end

      include Init
    end
  end
end
