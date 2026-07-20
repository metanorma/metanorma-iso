# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Simple document identifier with type attribute and text content.
      # Used for the multiple <docidentifier> elements in bibdata/bibitem.
      class DocIdentifier < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :primary, :boolean
        attribute :scope, :string
        attribute :language, :string
        attribute :value, :string

        xml do
          element "docidentifier"
          map_attribute "type", to: :type
          map_attribute "primary", to: :primary
          map_attribute "scope", to: :scope
          map_attribute "language", to: :language
          map_content to: :value
        end
      end
    end
  end
end
