require "isodoc"
require_relative "metadata"

module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert

      def default_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Cambria",serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Cambria",serif')
        m = options[:monospacefont] || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def initialize(options)
        super
        @wordstylesheet = generate_css(html_doc_path("wordstyle.scss"), false, default_fonts(options))
        @standardstylesheet = generate_css(html_doc_path("isodoc.scss"), false, default_fonts(options))
        @header = html_doc_path("header.html")
        @wordcoverpage = html_doc_path("word_iso_titlepage.html")
        @wordintropage = html_doc_path("word_iso_intro.html")
        @ulstyle = "l3"
        @olstyle = "l2"
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def implicit_reference(b)
        isocode = b.at(ns("./docidentifier")).text
        isocode == "IEV"
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

      def colophon(body, docxml)
        body.br **{ clear: "all", style: "page-break-before:left;mso-break-type:section-break" }
        body.div **{ class: "colophon" } do |div|
        end
      end
    end
  end
end
