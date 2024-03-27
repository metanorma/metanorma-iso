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
        if @dis && use_dis?(input_filename, file)
          swap_renderer(self, @dis, file, input_filename, debug)
          @dis.convert(input_filename, file, debug, output_filename)
        else
          super
        end
      end

      def use_dis?(input_filename, file)
        file ||= File.read(input_filename, encoding: "utf-8")
        stage = Nokogiri::XML(file, &:huge)
          .at(ns("//bibdata/status/stage"))&.text
        (/^[4569].$/.match?(stage) && @wordtemplate != "simple") ||
          (/^[0-3].$/.match?(stage) && @wordtemplate == "dis")
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
          indexsect_section(docxml, body)
          colophon_section(docxml, body)
        end
      end

      def br(out, pagebreak)
        out.br clear: "all", style: "page-break-before:#{pagebreak};" \
                                    "mso-break-type:section-break"
      end

      MAIN_ELEMENTS =
        "//sections/*[@displayorder] | //annex[@displayorder] | " \
        "//bibliography/*[@displayorder]".freeze

      def colophon_section(_isoxml, out)
        stage = @meta.get[:stage_int]
        return if !stage.nil? && stage < 60

        br(out, "left")
        out.div class: "colophon" do |div|
        end
      end

      def indexsect_section(isoxml, out)
        isoxml.xpath(ns("//indexsect")).each do |i|
          indexsect(i, out)
        end
      end

      def indexsect(elem, out)
        indexsect_title(elem, out)
        br(out, "auto")
        out.div class: "index" do |div|
          elem.children.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def indexsect_title(clause, out)
        br(out, "always")
        out.div class: "WordSection3" do |div|
          clause_name(clause, clause.at(ns("./title")), div, nil)
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

      def bibliography(node, out)
        node["hidden"] != "true" or return
        page_break(out)
        out.div do |div|
          div.h1 **bibliography_attrs do |h1|
            node&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(node, div, true)
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
        name.nil? and return
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
        name.nil? and return
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

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        measurement_units(node, out)
        out.div align: "center", class: "table_container" do |div|
          div.table **table_attrs(node) do |t|
            table_parse_core(node, t)
            table_parse_tail(node, t)
          end
        end
        @in_table = false
      end

      def table_parse_tail(node, out)
        (dl = node.at(ns("./dl"))) && parse(dl, out)
        node.xpath(ns("./source")).each { |n| parse(n, out) }
        node.xpath(ns("./note[not(@type = 'units')]"))
          .each { |n| parse(n, out) }
      end

      include BaseConvert
      include Init
    end
  end
end
