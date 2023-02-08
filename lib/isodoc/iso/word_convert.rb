require_relative "base_convert"
require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require_relative "word_dis_convert"

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
        init_dis(options)
      end

      def init_dis(opt)
        @wordtemplate = opt[:isowordtemplate]
        opt[:isowordbgstripcolor] ||= "true"
        @dis = ::IsoDoc::Iso::WordDISConvert.new(opt)
        @dis.bgstripcolor = opt[:isowordbgstripcolor]
      end

      def font_choice(options)
        if options[:script] == "Hans" then '"Source Han Sans",serif'
        else '"Cambria",serif'
        end
      end

      def default_fonts(options)
        { bodyfont: font_choice(options),
          headerfont: font_choice(options),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "11.0pt",
          monospacefontsize: "9.0pt",
          smallerfontsize: "10.0pt",
          footnotefontsize: "10.0pt" }
      end

      def default_file_locations(options)
        a = options[:alt] ? "style-human.scss" : "style-iso.scss"
        { htmlstylesheet: html_doc_path(a),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage.html"),
          wordintropage: html_doc_path("word_iso_intro.html"),
          ulstyle: "l3",
          olstyle: "l2" }
      end

      def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
        file = File.read(input_filename, encoding: "utf-8") if file.nil?
        docxml = Nokogiri::XML(file) { |config| config.huge }
        stage = docxml&.at(ns("//bibdata/status/stage"))&.text
        if @dis &&
            ((/^[4569].$/.match?(stage) && @wordtemplate != "simple") ||
            (/^[0-3].$/.match?(stage) && @wordtemplate == "dis"))
          @dis.convert(input_filename, file, debug, output_filename)
        else
          super
        end
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
          indexsect(docxml, body)
          colophon(body, docxml)
        end
      end

      def br(out, pagebreak)
        out.br clear: "all", style: "page-break-before:#{pagebreak};" \
                                    "mso-break-type:section-break"
      end

      def colophon(body, _docxml)
        stage = @meta.get[:stage_int]
        return if !stage.nil? && stage < 60

        br(body, "left")
        body.div class: "colophon" do |div|
        end
      end

      def indexsect(isoxml, out)
        isoxml.xpath(ns("//indexsect")).each do |i|
          indexsect_title(i, out)
          br(out, "auto")
          out.div class: "index" do |div|
            i.children.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end
      end

      def indexsect_title(clause, out)
        br(out, "always")
        out.div class: "WordSection3" do |div|
          clause_name(nil, clause.at(ns("./title")), div, nil)
        end
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
            style='mso-element:field-begin'></span><span
            style='mso-spacerun:yes'>&#xA0;</span>TOC
            \\o "1-#{level}" \\h \\z \\t "Heading
            1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1" <span
            style='mso-element:field-separator'></span></span>
        TOC
      end

      def footnote_reference_format(link)
        link.children =
          "<span class='MsoFootnoteReference'>#{to_xml(link.children)}</span>)"
      end

      def bibliography_attrs
        { class: "BiblioTitle" }
      end

      def bibliography(xml, out)
        (f = xml.at(ns(bibliography_xpath)) and f["hidden"] != "true") or return
        page_break(out)
        out.div do |div|
          div.h1 **bibliography_attrs do |h1|
            f&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(f, div, true)
        end
      end

      def bibliography_parse(node, out)
        node["hidden"] != true or return
        out.div do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out,
                             bibliography_attrs)
          biblio_list(node, div, true)
        end
      end

      def definition_parse(node, out)
        @definition = true
        super
        @definition = false
      end

      def para_class(node)
        if @definition && !@in_footnote then "Definition"
        elsif @foreword && !@in_footnote then "ForewordText"
        else super
        end
      end

      def termref_attrs
        { class: "Source" }
      end

      def termref_parse(node, out)
        out.p **termref_attrs do |p|
          node.children.each { |n| parse(n, p) }
        end
      end

      def figure_name_attrs(node)
        s = node.ancestors("annex").empty? ? "FigureTitle" : "AnnexFigureTitle"
        { class: s, style: "text-align:center;" }
      end

      def figure_name_parse(node, div, name)
        return if name.nil?

        div.p **figure_name_attrs(node) do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def table_title_attrs(node)
        s = node.ancestors("annex").empty? ? "Tabletitle" : "AnnexTableTitle"
        { class: s, style: "text-align:center;" }
      end

      def table_title_parse(node, out)
        name = node.at(ns("./name")) or return
        out.p **table_title_attrs(node) do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def annex_name(_annex, name, div)
        preceding_floating_titles(name, div)
        return if name.nil?

        name&.at(ns("./strong"))&.remove # supplied by CSS list numbering
        div.h1 class: "Annex" do |t|
          annex_name1(name, t)
          clause_parse_subtitle(name, t)
        end
      end

      def annex_name1(name, out)
        name.children.each do |c2|
          if c2.name == "span" && c2["class"] == "obligation"
            out.span style: "font-weight:normal;" do |s|
              c2.children.each { |c3| parse(c3, s) }
            end
          else parse(c2, out)
          end
        end
      end

      def table_attrs(node)
        ret = super
        node["class"] == "modspec" and ret[:width] = "100%"
        ret
      end

      include BaseConvert
      include Init
    end
  end
end
