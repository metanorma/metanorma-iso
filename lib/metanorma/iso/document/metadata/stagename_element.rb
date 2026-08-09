# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class StagenameElement < Lutaml::Model::Serializable
        attribute :abbreviation, :string
        attribute :value, :string

        xml do
          element "stagename"
          map_attribute "abbreviation", to: :abbreviation
          map_content to: :value
        end
      end
    end
  end
end
