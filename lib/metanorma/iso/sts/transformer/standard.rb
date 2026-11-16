# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Adapter conforming the STS transformer to the metanorma-core
        # +document_transformers+ contract: +.new(model, options)+ plus
        # +#transform+ returning a target (+::Sts::NisoSts::Standard+) that
        # responds to +#to_xml+. It hides the +Context+ construction behind
        # the (model, options) signature, so the metanorma-core driver treats
        # STS exactly like any other document-model transformer.
        class Standard
          # @param model [Object] a metanorma-document model
          #   (+Metanorma::Iso::Document::Root+), as returned by the reader's
          #   +.from_xml+.
          # @param options [Hash] processor options (accepted for interface
          #   conformance; not yet consumed).
          def initialize(model, options = {})
            @model = model
            @options = options
          end

          # @return [::Sts::NisoSts::Standard] the STS output model, which
          #   responds to +#to_xml+.
          def transform
            Transformer.transform(@model)
          end
        end
      end
    end
  end
end
