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

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"Source Han Sans",serif' :
                     '"Cambria",serif'),
                     headerfont: (options[:script] == "Hans" ? '"Source Han Sans",sans-serif' :
                                  '"Cambria",serif'),
                                  monospacefont: '"Courier New",monospace',
                                  normalfontsize: "11.0pt",
                                  monospacefontsize: "9.0pt",
                                  smallerfontsize: "10.0pt",
                                  footnotefontsize: "10.0pt",
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
        docxml&.xpath("//div[@class = 'boilerplate-license']").each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzWarningHdr"
          end
        end
        docxml&.xpath("//div[@class = 'boilerplate-copyright']").each do |d|
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
        docxml
      end

      def footnote_reference_format(a)
        a.children = "<span class='MsoFootnoteReference'>#{a.children.to_xml}</span>)"
      end

      include BaseConvert
      include Init
    end
  end
end
