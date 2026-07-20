# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Type of ISO/IEC document.
      class IsoDocumentType < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :semx_id, :string

        def self.values
          %w[internationalStandard technicalSpecification technicalReport
             publiclyAvailableSpecification internationalWorkshopAgreement guide
             interpretationSheet amendment technical-corrigendum]
        end

        xml do
          element "iso-document-type"
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
