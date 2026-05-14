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
          docx: "docx",
          pdf: "pdf",
          sts: "sts.xml",
          isosts: "iso.sts.xml",
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

      def use_presentation_xml(ext)
        return true if %i[html_alt sts isosts docx].include?(ext)

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
        when :docx
          # DOCX via Uniword (OOXML builders, no HTML intermediate).
          # The :doc format uses html2doc MHT path via WordConvert.
          # When use_presentation_xml returns true, isodoc_node is nil
          # and inname is the presentation XML file path.
          xml_input = isodoc_node ? isodoc_node.to_xml : inname
          template = resolve_docx_template(xml_input, options)
          IsoDoc::Iso::Docx::Adapter.new(template: template)
            .convert(xml_input, outname)
        when :pdf
          IsoDoc::Iso::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :sts
          IsoDoc::Iso::StsConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :isosts
          IsoDoc::Iso::IsoStsConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Iso::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end

      private

      # Resolve DOCX template type. Priority:
      #   1. Explicit :isowordtemplate option ("dis" or "simple")
      #   2. Auto-detect from document stage in bibdata
      #      - Stages 40-60, 90 → :dis
      #      - Stages 00-30     → :simple
      #   3. Default → :dis
      def resolve_docx_template(isodoc_node, options)
        wordtemplate = options[:isowordtemplate]

        # Extract stage from XML bibdata
        xml = isodoc_node.respond_to?(:to_xml) ? isodoc_node.to_xml : isodoc_node.to_s
        stage = Nokogiri::XML(xml, &:huge)
          .at("//bibdata/status/stage")&.text

        if /^[4569].$/.match?(stage) && wordtemplate != "simple"
          :dis
        elsif /^[0-3].$/.match?(stage) && wordtemplate != "dis"
          :simple
        elsif wordtemplate == "simple"
          :simple
        else
          :dis
        end
      end
    end
  end
end
