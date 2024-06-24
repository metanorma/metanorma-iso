require_relative "base_convert"
require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require_relative "word_dis_convert"
require_relative "word_convert_section"

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

      def footnote_reference_format(link)
        link.children =
          "<span class='MsoFootnoteReference'>#{to_xml(link.children)}</span>)"
      end

      def para_class(node)
        if @definition && !@in_footnote then "Definition"
        elsif @foreword && !@in_footnote then "ForewordText"
        else super
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

      def measurement_units(node, out)
        node.xpath(ns("./note[@type = 'units']")).each do |n|
          out.div class: "Note", style: "text-align: right;" do |p|
            n.children.each { |e| parse(e, p) }
            p.parent.xpath(".//p").each do |x|
              x["style"] = "text-align:right;page-break-after:avoid;"\
                           "page-break-inside:avoid;"
              x["class"] = "Note"
            end
          end
        end
      end

      include BaseConvert
      include Init
    end
  end
end
