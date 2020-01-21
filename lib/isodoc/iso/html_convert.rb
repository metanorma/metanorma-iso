require_relative "base_convert"
require "isodoc"
require_relative "metadata"

module IsoDoc
  module Iso
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' :
                     options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'),
        headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' :
                     options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'),
        monospacefont: (options[:alt] ?  '"Space Mono",monospace' :
                        '"Courier New",monospace'),
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

      def insertall_after_here(node, insert, name)
        node.children.each do |n|
          next unless n.name == name
          insert.next = n.remove
          insert = n
        end
        insert
      end

      def html_preface(docxml)
        super
        authority_cleanup(docxml)
        docxml
      end

      def authority_cleanup(docxml)
        dest = docxml.at("//div[@id = 'copyright']")
        auth = docxml.at("//div[@class = 'copyright']")
        auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
        dest and auth and dest.replace(auth.remove)
        dest = docxml.at("//div[@id = 'license']")
        auth = docxml.at("//div[@class = 'license']")
        auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
        dest and auth and dest.replace(auth.remove)
      end

      include BaseConvert
    end
  end
end
