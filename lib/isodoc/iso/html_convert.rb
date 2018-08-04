require "isodoc"
require_relative "metadata"

module IsoDoc
  module Iso
    class HtmlConvert < IsoDoc::HtmlConvert

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

      def alt_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Lato",sans-serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Lato",sans-serif')
        m = options[:monospacefont] || '"Space Mono",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def initialize(options)
        super
        if options[:alt]
          css = generate_css(html_doc_path("style-human.scss"), true, alt_fonts(options))
        else
          css = generate_css(html_doc_path("style-iso.scss"), true, default_fonts(options))
        end
        @htmlstylesheet = css
        @htmlcoverpage = html_doc_path("html_iso_titlepage.html")
        @htmlintropage = html_doc_path("html_iso_intro.html")
        @scripts = html_doc_path("scripts.html")
      end

      def implicit_reference(b)
        isocode = b.at(ns("./docidentifier")).text
        isocode == "IEV"
      end
    end
  end
end
