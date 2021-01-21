require_relative "base_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module Iso
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def googlefonts()
      <<~HEAD.freeze
      <link href="https://fonts.googleapis.com/css?family=Space+Mono:400,400i,700,700i&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet">
      HEAD
    end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"Source Han Sans",serif' :
                     options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'),
        headerfont: (options[:script] == "Hans" ? '"Source Han Sans",sans-serif' :
                     options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'),
        monospacefont: (options[:alt] ?  '"Space Mono",monospace' :
                        '"Courier New",monospace'),
                        normalfontsize: "1.0em",
                        smallerfontsize: "0.9em",
                        footnotefontsize: "0.9em",
                        monospacefontsize: "0.8em",
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: (options[:alt] ? html_doc_path("style-human.scss") :
                           html_doc_path("style-iso.scss")),
        htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
        htmlintropage: html_doc_path("html_iso_intro.html"),
        scripts: html_doc_path("scripts.html"),
        }
      end

      def footnote_reference_format(a)
        a.content = a.content + ")"
      end

      def table_th_center(docxml)
        docxml.xpath("//thead//th | //thead//td").each do |th|
          th["style"] += ";text-align:center;vertical-align:middle;"
        end
      end

      include BaseConvert
      include Init
    end
  end
end
