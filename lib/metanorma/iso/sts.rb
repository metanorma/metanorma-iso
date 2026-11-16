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
      autoload :VERSION, "metanorma/iso/sts/version"
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
        model = convert_to_model(input)
        xml = model.to_xml
        inject_namespaces(xml)
          .then { |x| inject_processing_meta(x) }
          .then { |x| fix_lang_attribute(x) }
      end

      # Convert input to the typed Sts::NisoSts::Standard model.
      # Use this when you need the model directly (e.g. passing to the
      # HTML renderer) to avoid the serialize→deserialize roundtrip
      # that can drop XML entities like &lt; in mixed_content contexts.
      #
      # @param input [String, Pathname, #read] the source XML.
      # @return [Sts::NisoSts::Standard] the typed STS model.
      def self.convert_to_model(input)
        source = Transformer::SourceDocument.parse(input)
        context = Transformer::Context.new(source)
        Transformer::DocumentTransformer.new(context).transform(source)
      end

      def self.inject_namespaces(xml)
        return xml if xml.include?("xmlns:xlink")
        xml.sub("<standard", '<standard xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML"')
      end

      def self.inject_processing_meta(xml)
        return xml if xml.include?("<processing-meta")
        meta = '<processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml="MathML 3.0" terminology-model="tbx"/>'
        # Linear scan for the end of the first <standard ...> opening tag.
        # Avoids the polynomial regex previously flagged by CodeQL.
        open_start = xml.index("<standard")
        return xml unless open_start
        open_end = xml.index(">", open_start)
        return xml unless open_end
        xml.dup.insert(open_end + 1, "\n  #{meta}")
      end

      def self.fix_lang_attribute(xml)
        xml.gsub(/\slang="([a-z-]+)"/, ' xml:lang="\\1"')
      end

      # Validate an ISO NISO STS XML string against the flavor constraints
      # (Schematron + lutaml-model rules; the ruleset ships with the OIML
      # X 999:2026 profile as the base).
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
