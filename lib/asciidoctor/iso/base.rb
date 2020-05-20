require "date"
require "nokogiri"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "isodoc"
require "fileutils"
require 'asciidoctor/iso/macros'

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "iso-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/iso".freeze

      Asciidoctor::Extensions.register do
        inline_macro Asciidoctor::Iso::TermRefInlineMacro
      end

      def html_converter(node)
        IsoDoc::Iso::HtmlConvert.new(html_extract_attributes(node))
      end

      def html_converter_alt(node)
        IsoDoc::Iso::HtmlConvert.new(html_extract_attributes(node).
                                     merge(alt: true))
      end

      def doc_converter(node)
        IsoDoc::Iso::WordConvert.new(doc_extract_attributes(node))
      end

      def pdf_converter(node)
        return nil if node.attr("no-pdf")
        IsoDoc::Iso::PdfConvert.new(doc_extract_attributes(node))
      end

      def init(node)
        super
        @amd = %w(amendment technical-corrigendum).include? node.attr("doctype")
      end

      def document(node)
        init(node)
        ret = makexml(node).to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
          html_converter_alt(node).convert(@filename + ".xml")
          FileUtils.mv "#{@filename}.html", "#{@filename}_alt.html"
          html_converter(node).convert(@filename + ".xml")
          doc_converter(node).convert(@filename + ".xml")
          pdf_converter(node)&.convert(@filename + ".xml")
        end
        @log.write(@localdir + @filename + ".err") unless @novalid
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            elsif lang == "fr"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-fr.yaml"))
            elsif lang == "zh" && script == "Hans"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-zh-Hans.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end
    end
  end
end
