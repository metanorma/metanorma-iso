require "metanorma/processor"

module Metanorma
  module Iso
    class Processor < Metanorma::Processor
      def initialize # rubocop:disable Lint/MissingSuper
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
          isosts: "iso.sts.xml",
          sts_html: "sts.html",
        )
      end

      def version
        "Metanorma::Iso #{Metanorma::Iso::VERSION}"
      end

      def fonts_manifest
        {
          "Cambria" => nil,
          "Cambria Math" => nil,
          "Times New Roman" => nil,
          "Source Han Sans" => nil,
          "Source Han Sans Normal" => nil,
          "Courier New" => nil,
          "Inter" => nil,
        }
      end

      # Register the native metanorma-document ISO-STS transformer for the
      # +:isosts+ leg. This declaration is inert while the QA gate
      # (+Metanorma::Iso::Sts.enabled?+) is off: {#output} intercepts
      # +:isosts+ with mnconvert and never reaches the base-class driver.
      # NISO +:sts+ is deliberately absent — it has no metanorma-document
      # transformer and stays on mnconvert.
      def document_transformers
        {
          isosts: {
            reader: Metanorma::IsoDocument::Root,
            transformer: Metanorma::Iso::Sts::Transformer::Standard,
            strip_default_namespace: true,
            post_process: lambda do |xml, _transformer, _options|
              Metanorma::Iso::Sts::Transformer::NbspProcessor.apply_to_text(xml)
            end,
          },
        }
      end

      def use_presentation_xml(ext)
        # When the native ISO-STS transformer is enabled it consumes semantic
        # XML (matching mnconvert's input_format: MN); while gated off, keep
        # the historical presentation-XML routing so mnconvert is unchanged.
        return false if ext == :isosts && Metanorma::Iso::Sts.enabled?
        return true if %i[html_alt sts isosts].include?(ext)

        super
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Iso::HtmlConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :html_alt
          IsoDoc::Iso::HtmlConvert.new(options.merge(alt: true))
            .convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Iso::WordConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Iso::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :sts
          IsoDoc::Iso::StsConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :isosts
          if Metanorma::Iso::Sts.enabled?
            # native metanorma-document transformer via the base-class
            # document_transformers driver (QA gate ON)
            super
          else
            # default: mnconvert (QA gate OFF)
            IsoDoc::Iso::IsoStsConvert.new(options)
              .convert(inname, isodoc_node, nil, outname)
          end
        when :sts_html
          # ISO-STS XML -> branded HTML via the native STS html_renderer.
          # Consumes semantic XML (the isodoc node, or +inname+ when nil),
          # the same source as the native +:isosts+ transformer.
          pxml = isodoc_node.nil? ? File.read(inname) : isodoc_node.to_s
          sts_xml = Metanorma::Iso::Sts.convert(pxml)
          File.write(outname, Metanorma::Iso::Sts.render_html(sts_xml))
        when :presentation
          IsoDoc::Iso::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
