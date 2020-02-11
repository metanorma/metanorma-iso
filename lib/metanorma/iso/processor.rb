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
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::ISO #{Metanorma::ISO::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Iso::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :html_alt
          IsoDoc::Iso::HtmlConvert.new(options.merge(alt: true)).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Iso::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Iso::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end

    end
  end
end
