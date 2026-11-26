# frozen_string_literal: true

require "sts"
require "metanorma/document"

module Metanorma
  autoload :IsoDocument, "metanorma/iso/document"

  module Iso
    # NISO STS toolkit for the ISO flavor: the OIML STS engine
    # (Metanorma::Oiml::Sts) ported wholesale — same transformer tree,
    # same post-processing, same validator machinery; the module
    # namespace and the source reader are the only per-flavor deltas.
    #
    # Public API:
    #   Metanorma::Iso::Sts.convert(xml)        # -> sts xml string
    #   Metanorma::Iso::Sts.validate(xml)       # -> ValidationReport
    #   Metanorma::Iso::Sts.render_html(model)  # -> branded HTML
    #   Metanorma::Iso::Sts::Cli.start(argv)    # Thor CLI entry
    #
    # The native document-model driver is the production +:isosts+ path;
    # mnconvert (+IsoDoc::Iso::IsoStsConvert+) is retained as the rollback
    # escape (+METANORMA_ISO_NATIVE_STS=0+ or +Metanorma::Iso::Sts.enabled
    # = false+). NISO +:sts+ stays on mnconvert (+IsoDoc::Iso::StsConvert+,
    # whose emission the OutputSanitizer repairs to schema-valid NISO STS).
    module Sts
      autoload :Transformer, "metanorma/iso/sts/transformer"
      autoload :MathmlBuilder, "metanorma/iso/sts/mathml_builder"
      autoload :HtmlRenderer, "metanorma/iso/sts/html_renderer"
      autoload :ParityValidator, "metanorma/iso/sts/parity_validator"
      autoload :Validator, "metanorma/iso/sts/validator"
      autoload :ValidationReport, "metanorma/iso/sts/validation_report"
      autoload :Cli, "metanorma/iso/sts/cli"
      autoload :OutputSanitizer, "metanorma/iso/sts/output_sanitizer"

      class << self
        # Explicit override (true/false). When nil, falls back to the
        # +METANORMA_ISO_NATIVE_STS+ environment variable (only "0"
        # disables; the native driver is the default).
        attr_writer :enabled

        # @return [Boolean] whether the native STS driver serves +:isosts+.
        def enabled?
          return @enabled unless @enabled.nil?

          ENV["METANORMA_ISO_NATIVE_STS"] != "0"
        end
      end

      # Convert a Metanorma ISO presentation XML string (or anything
      # `SourceDocument.parse` accepts) into an ISO NISO STS XML string.
      #
      # @param input [String, Pathname, #read] the source XML.
      # @return [String] ISO NISO STS XML.
      def self.convert(input)
        Lutaml::Model::Config.with_adapter(xml: :leptris) do
          convert_inner(input)
        end
      end

      # The STS serialization is deterministic only under the leptris XML
      # adapter: the Nokogiri adapter's serialization normalizes U+00A0
      # and collapses provision-table indentation, which breaks golden
      # parity (metanorma-iso#1760 / metanorma-document#165). The scoped
      # override keeps the process-global adapter untouched.
      def self.convert_inner(input)
        model = convert_to_model(input)
        xml = model.to_xml
        # processing-meta is valid per the delivery-gate schema (NISO STS
        # extended-1.2 MathML3); the older extended-1 package had no slot
        # for it. See sts-specs reference-docs.
        inject_namespaces(xml)
          .then { |x| inject_processing_meta(x) }
          .then { |x| fix_lang_attribute(x) }
          .then { |x| Transformer::NbspProcessor.apply_to_text(x) }
      end

      # Convert input to the typed Sts::NisoSts::Standard model.
      # Use this when you need the model directly (e.g. passing to the
      # HTML renderer) to avoid the serialize→deserialize roundtrip
      # that can drop XML entities like &lt; in mixed_content contexts.
      #
      # @param input [String, Pathname, #read] the source XML.
      # @return [Sts::NisoSts::Standard] the typed STS model.
      def self.convert_to_model(input, presentation_xml: nil)
        xml_string = input.respond_to?(:read) ? input.read : input.to_s
        source = Transformer::SourceDocument.parse(xml_string)
        pres = presentation_xml || (presentation_input?(xml_string) ? xml_string : nil)
        context = Transformer::Context.new(source, presentation_xml: pres)
        Transformer::DocumentTransformer.new(context).transform(source)
      end

      # A presentation-typed document carries the rendered requirement
      # provision tables (<fmt-provision>); wiring them into the context
      # makes requirement tables emit 1:1 with the rendered output.
      PRESENTATION_TYPE_RE = /<metanorma\b[^>]*\btype="presentation"/.freeze
      def self.presentation_input?(xml_string)
        PRESENTATION_TYPE_RE.match?(xml_string)
      end

      def self.inject_namespaces(xml)
        missing = []
        missing << 'xmlns:mml="http://www.w3.org/1998/Math/MathML"' unless xml.include?("xmlns:mml")
        missing << 'xmlns:xlink="http://www.w3.org/1999/xlink"' unless xml.include?("xmlns:xlink")
        return xml if missing.empty?

        xml.sub("<standard", "<standard #{missing.join(' ')}")
      end

      # <processing-meta> per the IEC/ISO Coding Guidelines ed. 2.1
      # §4.3.2: a child of <standard> declaring the coding profile
      # (tagset-family, base-tagset, table-model, mathml-version,
      # math-representation, terminology-model) plus the
      # custom-meta-group naming the guidelines edition.
      def self.inject_processing_meta(xml)
        return xml if xml.include?("<processing-meta")

        meta = processing_meta_element
        # Linear scan for the end of the first <standard ...> opening tag.
        # Avoids the polynomial regex previously flagged by CodeQL.
        open_start = xml.index("<standard")
        return xml unless open_start
        open_end = xml.index(">", open_start)
        return xml unless open_end
        xml.dup.insert(open_end + 1, "\n  #{meta}")
      end

      def self.processing_meta_element
        <<~XML.chomp
          <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml-version="3.0" math-representation="mathml" terminology-model="tbx"><custom-meta-group><custom-meta><meta-name>iec_iso_coding_guidelines_edition</meta-name><meta-value>2.1</meta-value></custom-meta></custom-meta-group></processing-meta>
        XML
      end

      def self.fix_lang_attribute(xml)
        xml.gsub(/\slang="([a-z-]+)"/, ' xml:lang="\\1"')
      end

      # Validate an ISO NISO STS XML string against the flavor constraints
      # (IEC/ISO NISO STS Coding Guidelines ed 2.1; error findings fail
      # +valid?+, warnings are report-only).
      #
      # @param xml [String, Pathname, #read] the STS XML.
      # @return [ValidationReport]
      def self.validate(xml)
        Validator.new.validate(xml)
      end

      # Render an STS model (or XML string) as a branded HTML page.
      #
      # @param model_or_xml [Sts::NisoSts::Standard, String, #read]
      #   a typed STS model or STS XML. Models built programmatically
      #   are round-tripped through to_xml / from_xml so the renderer
      #   sees a typed tree with element_order populated (lutaml-model
      #   only records element_order during XML parsing, and the
      #   renderer's document-order walk relies on it).
      # @param full_document [Boolean] wrap the fragment in the branded
      #   page shell (default); +false+ returns just the body fragment.
      # @return [String] HTML.
      def self.render_html(model_or_xml, full_document: true)
        html_input = coerce_html_input(model_or_xml)
        HtmlRenderer.render(html_input, full_document: full_document)
      end

      # Strings and IO go straight through; typed models are serialized
      # and re-parsed so the renderer walks a tree with element_order set.
      def self.coerce_html_input(input)
        return input.to_s unless input.is_a?(Lutaml::Model::Serializable)

        input.to_xml
      end
    end
  end
end
