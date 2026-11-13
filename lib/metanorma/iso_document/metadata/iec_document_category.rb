# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Categories of IEC standards document.
      class IecDocumentCategory < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :semx_id, :string

        def self.values
          %w[emc safety environment quality-assurance]
        end

        xml do
          element "iec-document-category"
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
