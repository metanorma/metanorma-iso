# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Adapter conforming to the metanorma-core
        # +Processor#document_transformers+ contract: +.new(model, options)+,
        # where +model+ is the reader's parse result
        # (Metanorma::Iso::Document::Root); +#transform+ returns a target
        # responding to +#to_xml+.
        #
        # The adapter is its own target: its +#to_xml+ runs the full
        # {DocumentTransformer#transform_to_xml} pipeline (model build plus the
        # namespace / processing-meta / lang post-processing on the serialised
        # string), so the pipeline output matches the standalone
        # {Metanorma::Iso::Sts::Transformer.convert}. Returning the raw
        # +#transform+ model instead would drop that post-processing.
        class Standard
          def initialize(model, options = {})
            @model = model
            @options = options
          end

          def transform
            @document_transformer = DocumentTransformer.new(
              Context.new(source, presentation_xml: presentation_xml)
            )
            self
          end

          def to_xml(**_options)
            @document_transformer.transform_to_xml(source)
          end

          private

          # The driver hands over the reader's parse result (the typed
          # Root); the standalone path may pass an already-wrapped
          # {SourceDocument}. Normalize to the wrapper either way.
          def source
            return @model if @model.is_a?(Transformer::SourceDocument)

            Transformer::SourceDocument.new(@model)
          end

          # The sibling presentation XML produced by the same compile
          # (document.presentation.xml next to the source document).
          # Requirement blocks prefer its <fmt-provision> tables — the
          # requirement's own rendered table — 1:1. Accepts either the
          # XML text or a file path via options; falls back to deriving
          # the sibling path from the compile's source filename. nil when
          # unavailable (standalone convert) — requirements then
          # synthesize their tables from the semantic components.
          def presentation_xml
            explicit = @options[:sts_presentation_xml]
            return File.read(explicit) if explicit && File.file?(explicit)
            return explicit if explicit.is_a?(String)

            from_source_filename
          end

          def from_source_filename
            src = @options[:sourcefilename]
            return nil unless src.is_a?(String) && File.file?(src)

            sibling = src.sub(/\.[^.]+\z/, ".presentation.xml")
            File.read(sibling) if File.file?(sibling)
          end
        end
      end
    end
  end
end
