# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class IsoDocumentStatus < Lutaml::Model::Serializable
        attribute :stage, StageElement, collection: true
        attribute :stage_abbreviation, :string
        attribute :substage, IsoDocumentSubstageCodes
        attribute :substage_abbreviation, :string
        attribute :iteration, :integer
        attribute :semx_id, :string

        xml do
          element "status"
          map_element "stage", to: :stage
          map_element "stage-abbreviation", to: :stage_abbreviation
          map_element "substage", to: :substage
          map_element "substage-abbreviation", to: :substage_abbreviation
          map_element "iteration", to: :iteration
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
