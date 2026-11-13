# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class LanguageElement < Lutaml::Model::Serializable
        attribute :current, :string
        attribute :value, :string

        xml do
          element "language"
          map_attribute "current", to: :current
          map_content to: :value
        end
      end
    end
  end
end
