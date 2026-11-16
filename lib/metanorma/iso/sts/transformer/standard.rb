# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Adapter conforming to the metanorma-core
        # +Processor#document_transformers+ contract: +.new(model, options)+,
        # where +model+ is the {SourceDocument} produced by
        # {SourceDocument.from_xml}; +#transform+ returns a target responding to
        # +#to_xml+.
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
            @document_transformer = DocumentTransformer.new(Context.new(@model))
            self
          end

          def to_xml(**_options)
            @document_transformer.transform_to_xml(@model)
          end
        end
      end
    end
  end
end
