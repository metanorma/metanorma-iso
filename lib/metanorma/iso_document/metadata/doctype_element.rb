# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      class DoctypeElement < Lutaml::Model::Serializable
        attribute :language, :string
        attribute :abbreviation, :string
        attribute :value, :string

        xml do
          element "doctype"
          map_attribute "language", to: :language, render_empty: true
          map_attribute "abbreviation", to: :abbreviation
          map_content to: :value
        end
      end
    end
  end
end
