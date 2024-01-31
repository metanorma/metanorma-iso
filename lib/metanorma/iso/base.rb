require "date"
require "nokogiri"
require "json"
require "pathname"
require "open-uri"
require "isodoc"
require "fileutils"
require_relative "processor"

module Metanorma
  module ISO
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "iso-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/iso".freeze

      def requirements_processor
        ::Metanorma::Requirements::Iso
      end

      def html_converter(node)
        IsoDoc::Iso::HtmlConvert.new(html_extract_attributes(node))
      end

      def html_converter_alt(node)
        IsoDoc::Iso::HtmlConvert.new(html_extract_attributes(node)
                                     .merge(alt: true))
      end

      def doc_converter(node)
        IsoDoc::Iso::WordConvert.new(doc_extract_attributes(node))
      end

      def doc_extract_attributes(node)
        super.merge(isowordtemplate: node.attr("iso-word-template"),
                    isowordbgstripcolor: node.attr("iso-word-bg-strip-color"))
      end

      def pdf_converter(node)
        return nil if node.attr("no-pdf")

        IsoDoc::Iso::PdfConvert.new(pdf_extract_attributes(node))
      end

      def sts_converter(node)
        return nil if node.attr("no-pdf")

        IsoDoc::Iso::StsConvert.new(html_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Iso::PresentationXMLConvert
          .new(html_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Iso::Processor.new.output_formats))
      end

      def init(node)
        super
        @amd = %w(amendment technical-corrigendum).include? doctype(node)
        @vocab = node.attr("docsubtype") == "vocabulary"
        @validate_years = node.attr("validate-years")
      end

      def toc_default
        { word_levels: 3, html_levels: 2, pdf_levels: 3 }
      end

      def ol_attrs(node)
        attr_code(keep_attrs(node)
                  .merge(id: ::Metanorma::Utils::anchor_or_uuid(node),
                         "explicit-type": olist_style(node.attributes[1]),
                         start: node.attr("start")))
      end

      def admonition_name(node)
        name = super
        a = node.attr("type") and ["editorial"].each do |t|
          name = t if a.casecmp(t).zero?
        end
        name
      end

      def metadata_attrs(node)
        ret = super
        a = node.attr("document-scheme") and
          ret += "<presentation-metadata><name>document-scheme</name>" \
          "<value>#{a}</value></presentation-metadata>"
        ret
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert("#{@filename}.xml")
        html_converter_alt(node).convert("#{@filename}.presentation.xml",
                                         nil, false, "#{@filename}_alt.html")
        html_converter(node).convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.html")
        doc_converter(node).convert("#{@filename}.presentation.xml",
                                    nil, false, "#{@filename}.doc")
        pdf_converter(node)&.convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.pdf")
        # sts_converter(node)&.convert(@filename + ".xml")
      end
    end
  end
end
