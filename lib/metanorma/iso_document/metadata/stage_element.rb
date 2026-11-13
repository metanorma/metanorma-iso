# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      class StageElement < Lutaml::Model::Serializable
        attribute :abbreviation, :string
        attribute :language, :string
        attribute :type, :string
        attribute :value, :string, collection: true
        attribute :br, Metanorma::Document::Components::Inline::BrElement,
                  collection: true

        xml do
          element "stage"
          mixed_content
          map_attribute "abbreviation", to: :abbreviation
          map_attribute "language", to: :language, render_empty: true
          map_attribute "type", to: :type
          map_content to: :value
          map_element "br", to: :br
        end
      end
    end
  end
end
