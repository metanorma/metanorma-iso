require_relative "base_convert"
require "isodoc"
require_relative "metadata"

module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' :
                     '"Cambria",serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' :
                       '"Cambria",serif'),
          monospacefont: '"Courier New",monospace',
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: (options[:alt] ? html_doc_path("style-human.scss") :
                           html_doc_path("style-iso.scss")),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          scripts: html_doc_path("scripts.html"),
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

      def colophon(body, docxml)
        stage =  @meta.get[:stage_int]
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
          d = t.add_previous_sibling("<div class='figdl'/>")
          t.parent = d.first
        end
      end

      # force Annex h2 down to be p.h2Annex, so it is not picked up by ToC
      def word_annex_cleanup1(docxml, i)
        docxml.xpath("//h#{i}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "h#{i}Annex"
        end
      end

      def word_annex_cleanup(docxml)
        word_annex_cleanup1(docxml, 2)
        word_annex_cleanup1(docxml, 3)
        word_annex_cleanup1(docxml, 4)
        word_annex_cleanup1(docxml, 5)
        word_annex_cleanup1(docxml, 6)
      end

      def authority_hdr_cleanup(docxml)
        docxml&.xpath("//div[@class = 'license']").each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzWarningHdr"
          end
        end
        docxml&.xpath("//div[@class = 'copyright']").each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzCopyrightHdr"
          end
        end
      end

      def authority_cleanup(docxml)
        insert = docxml.at("//div[@id = 'license']")
        auth = docxml&.at("//div[@class = 'license']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each { |p| p["class"] = "zzWarning" }
        auth and insert.children = auth
        insert = docxml.at("//div[@id = 'copyright']")
        auth = docxml&.at("//div[@class = 'copyright']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each { |p| p["class"] = "zzCopyright" }
        auth&.xpath(".//p[@id = 'authority2']")&.each { |p| p["class"] = "zzCopyright1" }
        auth&.xpath(".//p[@id = 'authority3']")&.each { |p| p["class"] = "zzAddress" }
        auth and insert.children = auth
      end

      def word_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        super
        docxml
      end

      include BaseConvert
    end
  end
end
