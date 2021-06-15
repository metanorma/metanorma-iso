require_relative "base_convert"
require "isodoc"
require_relative "init"

module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
        @wordToClevels = options[:doctoclevels].to_i
        @wordToClevels = 3 if @wordToClevels.zero?
        @htmlToClevels = options[:htmltoclevels].to_i
        @htmlToClevels = 3 if @htmlToClevels.zero?
      end

      def font_choice(options)
        if options[:script] == "Hans" then '"Source Han Sans",serif'
        else '"Cambria",serif'
        end
      end

      def default_fonts(options)
        {
          bodyfont: font_choice(options),
          headerfont: font_choice(options),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "11.0pt",
          monospacefontsize: "9.0pt",
          smallerfontsize: "10.0pt",
          footnotefontsize: "10.0pt",
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: (if options[:alt]
                             html_doc_path("style-human.scss")
                           else
                             html_doc_path("style-iso.scss")
                           end),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage.html"),
          wordintropage: html_doc_path("word_iso_intro.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
          colophon(body, docxml)
        end
      end

      def colophon(body, _docxml)
        stage = @meta.get[:stage_int]
        return if !stage.nil? && stage < 60

        body.br **{ clear: "all", style: "page-break-before:left;"\
                    "mso-break-type:section-break" }
        body.div **{ class: "colophon" } do |div|
        end
      end

      def figure_cleanup(xml)
        super
        xml.xpath("//div[@class = 'figure']//table[@class = 'dl']").each do |t|
          t["class"] = "figdl"
          d = t.add_previous_sibling("<div class='figdl' "\
                                     "style='page-break-after:avoid;'/>")
          t.parent = d.first
        end
      end

      # force Annex h2 down to be p.h2Annex, so it is not picked up by ToC
      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "h#{lvl}Annex"
        end
      end

      def word_annex_cleanup(docxml)
        (2..6).each { |i| word_annex_cleanup1(docxml, i) }
      end

      def word_annex_cleanup_h1(docxml)
        docxml.xpath("//h1[@class = 'Annex']").each do |h|
          h.name = "p"
          h["class"] = "ANNEX"
        end
        docxml
          .xpath("//*[@class = 'BiblioTitle' or @class = 'ForewordTitle' or "\
        "@class = 'IntroTitle']").each do |h|
          h.name = "p"
        end
      end

      def style_cleanup(docxml)
        word_annex_cleanup_h1(docxml)
        style_cleanup1(docxml)
      end

      def style_cleanup1(docxml)
        docxml.xpath("//*[@class = 'example']").each do |p|
          p["class"] = "Example"
        end
      end

      def authority_hdr_cleanup(docxml)
        docxml&.xpath("//div[@class = 'boilerplate-license']")&.each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzWarningHdr"
          end
        end
        docxml&.xpath("//div[@class = 'boilerplate-copyright']")&.each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzCopyrightHdr"
          end
        end
      end

      def authority_cleanup(docxml)
        insert = docxml.at("//div[@id = 'boilerplate-license-destination']")
        auth = docxml&.at("//div[@class = 'boilerplate-license']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each { |p| p["class"] = "zzWarning" }
        auth and insert.children = auth
        insert = docxml.at("//div[@id = 'boilerplate-copyright-destination']")
        auth = docxml&.at("//div[@class = 'boilerplate-copyright']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each { |p| p["class"] = "zzCopyright" }
        auth&.xpath(".//p[@id = 'boilerplate-message']")&.each { |p| p["class"] = "zzCopyright1" }
        auth&.xpath(".//p[@id = 'boilerplate-address']")&.each { |p| p["class"] = "zzAddress" }
        auth&.xpath(".//p[@id = 'boilerplate-place']")&.each { |p| p["class"] = "zzCopyright1" }
        auth and insert.children = auth
      end

      def word_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        super
        style_cleanup(docxml)
        docxml
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
            style='mso-element:field-begin'></span><span
            style='mso-spacerun:yes'>&#xA0;</span>TOC
            \\o &quot;1-#{level}&quot; \\h \\z \\t &quot;Heading
            1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1&quot; <span
            style='mso-element:field-separator'></span></span>
        TOC
      end

      def footnote_reference_format(link)
        link.children =
          "<span class='MsoFootnoteReference'>#{link.children.to_xml}</span>)"
      end

      def bibliography(xml, out)
        f = xml.at(ns(bibliography_xpath)) and f["hidden"] != "true" or return
        page_break(out)
        out.div do |div|
          div.h1 **{ class: "BiblioTitle" } do |h1|
            f&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(f, div, true)
        end
      end

      def bibliography_parse(node, out)
        node["hidden"] != true or return
        out.div do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out,
                             { class: "BiblioTitle" })
          biblio_list(node, div, true)
        end
      end

      def para_class(node)
        if !node.ancestors("definition").empty? && !@in_footnote
          "Definition"
        elsif !node.ancestors("foreword").empty? && !@in_footnote
          "ForewordText"
        else
          super
        end
      end

      def termref_parse(node, out)
        out.p **{ class: "Source" } do |p|
          p << "[TERMREF]"
          node.children.each { |n| parse(n, p) }
          p << "[/TERMREF]"
        end
      end

      def figure_name_parse(node, div, name)
        return if name.nil?

        s = node.ancestors("annex").empty? ? "FigureTitle" : "AnnexFigureTitle"
        div.p **{ class: s, style: "text-align:center;" } do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def table_title_parse(node, out)
        name = node.at(ns("./name")) or return
        s = node.ancestors("annex").empty? ? "Tabletitle" : "AnnexTableTitle"
        out.p **{ class: s, style: "text-align:center;" } do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def annex_name(_annex, name, div)
        return if name.nil?

        name&.at(ns("./strong"))&.remove # supplied by CSS list numbering
        div.h1 **{ class: "Annex" } do |t|
          name.children.each { |c2| parse(c2, t) }
        end
      end

      include BaseConvert
      include Init
    end
  end
end
