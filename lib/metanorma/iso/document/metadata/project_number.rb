# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class ProjectNumber < Lutaml::Model::Serializable
        attribute :part, :string
        attribute :amendment, :string
        attribute :origyr, :string
        attribute :value, :string

        xml do
          element "project-number"
          map_attribute "part", to: :part
          map_attribute "amendment", to: :amendment
          map_attribute "origyr", to: :origyr
          map_content to: :value
        end
      end
    end
  end
end
