# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Substage-level code in the International Harmonized Stage Codes.
      # These codes are used by ISO and IEC to indicate development stage.
      #
      # NOTE: See https://www.iso.org/stage-codes.html for the full list.
      class IsoDocumentSubstageCodes < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :semx_id, :string

        def self.values
          %w[00 20 60 90 92 93 98 99]
        end

        xml do
          element "iso-document-substage-codes"
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
