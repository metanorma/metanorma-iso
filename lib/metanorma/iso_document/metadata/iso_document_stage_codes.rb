# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Stage-level code in the International Harmonized Stage Codes
      # used by ISO/IEC for their documents.
      #
      # NOTE: See https://www.iso.org/stage-codes.html
      class IsoDocumentStageCodes < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :semx_id, :string

        def self.values
          %w[00 10 20 30 40 50 60 90 95]
        end

        xml do
          element "iso-document-stage-codes"
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
