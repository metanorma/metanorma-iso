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

      # Register the native metanorma-document STS transformer for the
      # +:isosts+ leg (the OIML engine ported to Metanorma::Iso::Sts).
      # This is the production path; METANORMA_ISO_NATIVE_STS=0 rolls back
      # to mnconvert. NISO +:sts+ stays on mnconvert, whose emission the
      # OutputSanitizer repairs to schema-valid NISO STS.
      def document_transformers
        {
          isosts: {
            reader: Metanorma::Iso::Document::Root,
            transformer: Metanorma::Iso::Sts::Transformer::Standard,
            strip_default_namespace: true,
            post_process: lambda do |xml, _transformer, _options|
              Metanorma::Iso::Sts.inject_namespaces(xml)
                .then { |x| Metanorma::Iso::Sts.inject_processing_meta(x) }
                .then { |x| Metanorma::Iso::Sts.fix_lang_attribute(x) }
            end,
          },
        }
      end

      def use_presentation_xml(ext)
        # When the native ISO-STS transformer is enabled it consumes semantic
        # XML (matching mnconvert's input_format: MN); while gated off, keep
        # the historical presentation-XML routing so mnconvert is unchanged.
        return false if ext == :isosts && Metanorma::Iso::Sts.enabled?
        return false if ext == :sts_html
        return true if %i[html_alt sts isosts doc docx].include?(ext)

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
        when :doc, :docx
          output_word(isodoc_node, inname, outname, options)
        when :pdf
          IsoDoc::Iso::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :sts
          IsoDoc::Iso::StsConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :sts_html
          output_sts_html(isodoc_node, inname, outname)
        when :isosts
          if Metanorma::Iso::Sts.enabled?
            # native metanorma-document transformer via the base-class
            # document_transformers driver (default)
            super
          else
            # rollback: mnconvert (METANORMA_ISO_NATIVE_STS=0)
            IsoDoc::Iso::IsoStsConvert.new(options)
              .convert(inname, isodoc_node, nil, outname)
          end
        when :presentation
          IsoDoc::Iso::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end

      private

      def output_word(isodoc_node, inname, outname, options)
        # MHTML and DOCX use the same Uniword adapter.
        # When use_presentation_xml returns true, isodoc_node is nil
        # and inname is the presentation XML file path.
        xml_input = isodoc_node ? isodoc_node.to_xml : inname
        template = resolve_docx_template(xml_input, options)
        IsoDoc::Iso::Docx::Adapter.new(template: template)
          .convert(xml_input, outname)
      end

      def output_sts_html(isodoc_node, inname, outname)
        # PXML → ISO-STS XML → branded HTML. Consumes the presentation
        # XML (semantic), not the isodoc-rendered node — the native
        # transformer reads the typed IsoDocument::Root directly.
        # The compile layer hands the semantic XML over as a String;
        # isodoc hands off by file path (nil) or parsed node.
        pxml = case isodoc_node
               when String then isodoc_node
               when nil then File.read(inname)
               else isodoc_node.to_xml
               end
        sts_xml = Metanorma::Iso::Sts.convert(pxml)
        html = Metanorma::Iso::Sts.render_html(sts_xml)
        File.write(outname, html)
      end

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
        xml = File.read(xml, encoding: "utf-8") if File.file?(xml)
        stage = Nokogiri::XML(xml, &:huge)
          .at("//*[local-name()='bibdata']/*[local-name()='status']/*[local-name()='stage']")&.text

        if wordtemplate == "simple" ||
            (wordtemplate != "dis" && /^[0-3].$/.match?(stage))
          :simple
        else
          :dis
        end
      end
    end
  end
end
