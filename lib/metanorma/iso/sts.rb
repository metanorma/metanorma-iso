# frozen_string_literal: true

require "sts"
require "metanorma/document"

module Metanorma
  autoload :IsoDocument, "metanorma/iso_document"

  module Iso
    # Native metanorma-document ISO-STS transformer (the +:isosts+ output
    # format).
    #
    # QA GATE: this path is OFF by default. mnconvert
    # (+IsoDoc::Iso::IsoStsConvert+) remains the +:isosts+ default until the
    # ISO-STS transformer QA is signed off; only then is the default flipped.
    # Enable for testing / after sign-off with +METANORMA_ISO_NATIVE_STS=1+ or
    # +Metanorma::Iso::Sts.enabled = true+.
    #
    # NISO +:sts+ has no metanorma-document transformer and always stays on
    # mnconvert; this gate governs +:isosts+ only.
    module Sts
      autoload :Transformer, "metanorma/iso/sts/transformer"
      autoload :HtmlRenderer, "metanorma/iso/sts/html_renderer"

      class << self
        # Explicit override (true/false). When nil, falls back to the
        # +METANORMA_ISO_NATIVE_STS+ environment variable.
        attr_writer :enabled

        # @return [Boolean] whether the native ISO-STS transformer is enabled.
        #   Defaults to true — the native document-model driver is now the
        #   production path. Set +@enabled = false+ or
        #   +METANORMA_ISO_NATIVE_STS=0+ to fall back to mnconvert (one
        #   release cycle's rollback safety).
        def enabled?
          return @enabled unless @enabled.nil?

          ENV["METANORMA_ISO_NATIVE_STS"] != "0"
        end

        # Convert a Metanorma ISO XML input into an ISO-STS XML string.
        #
        # @param input [String, Pathname, #read, Metanorma::IsoDocument::Root]
        #   the source. Strings/pathnames/IO are parsed as XML.
        # @return [String] ISO-STS XML.
        def convert(input)
          model_to_xml(convert_to_model(input))
        end

        # Convert a Metanorma ISO XML input into the typed
        # +Sts::IsoSts::Standard+ model. Use this when you need the model
        # directly (e.g. passing to the HTML renderer) to avoid the
        # serialize→deserialize roundtrip.
        #
        # @param input see #convert.
        # @return [Sts::IsoSts::Standard]
        def convert_to_model(input)
          source = Transformer::SourceDocument.parse(input)
          context = Transformer::Context.new(source)
          Transformer::DocumentTransformer.new(context).transform(source)
        end

        # Render an ISO-STS model (or XML string) as a branded HTML page.
        #
        # @param model_or_xml [Sts::IsoSts::Standard, String, #read]
        #   a typed STS model or ISO-STS XML. Models built programmatically
        #   (e.g. by {convert_to_model}) are round-tripped through to_xml /
        #   from_xml so the renderer sees a typed tree with element_order
        #   populated (lutaml-model only records element_order during XML
        #   parsing, and the renderer's document-order walk relies on it).
        # @param full_document [Boolean] wrap the fragment in the branded
        #   page shell (default); +false+ returns just the body fragment.
        # @return [String] HTML.
        def render_html(model_or_xml, full_document: true)
          html_input = coerce_html_input(model_or_xml)
          HtmlRenderer.render(html_input, full_document: full_document)
        end

        private

        # Strings and IO go straight through; typed models are serialized
        # and re-parsed so the renderer walks a tree with element_order set.
        def coerce_html_input(input)
          return input.to_s unless input.is_a?(Lutaml::Model::Serializable)

          input.to_xml
        end

        # Serializes the typed model and applies the post-processing that
        # turns lutaml-model's raw output into the final ISO-STS document
        # (NBSP normalization on text content).
        def model_to_xml(model)
          Transformer::NbspProcessor.apply_to_text(model.to_xml)
        end
      end
    end
  end
end
