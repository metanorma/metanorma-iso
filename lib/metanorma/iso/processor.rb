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
        {
          html: "html",
          html_alt: "alt.html",
          doc: "doc"
        }
      end

      def version
        "Asciidoctor::ISO #{Asciidoctor::ISO::VERSION}/IsoDoc #{IsoDoc::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Iso::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :html_alt
          IsoDoc::Iso::HtmlConvert.new(options.merge(alt: true)).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Iso::WordConvert.new(options).convert(outname, isodoc_node)
        end
      end

    end
  end
end
