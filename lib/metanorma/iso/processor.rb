require "metanorma/processor"

module Metanorma
  module Iso
    class Processor < Metanorma::Processor

      def initialize
        @short = :iso
        @input_format = :asciidoc
        @asciidoctor_backend = :iso
      end

      def output_formats
        super.merge(
          html: "html",
          html_alt: "alt.html",
          doc: "doc",
          pdf: "pdf",
          sts: "sts.xml",
          isosts: "iso.sts.xml"
        )
      end

      def version
        "Metanorma::ISO #{Metanorma::ISO::VERSION}"
      end

      def use_presentation_xml(ext)
        return true if ext == :html_alt
        super
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::Iso::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :html_alt
          IsoDoc::Iso::HtmlConvert.new(options.merge(alt: true)).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Iso::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Iso::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :sts
          IsoDoc::Iso::StsConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :isosts
          IsoDoc::Iso::IsoStsConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Iso::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end

    end
  end
end
