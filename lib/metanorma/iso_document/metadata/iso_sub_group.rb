# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Editorial group set up in ISO or IEC to work on producing documents.
      class IsoSubGroup < Lutaml::Model::Serializable
        # Type of editorial group.
        attribute :type, :string

        # Number used to identify editorial group.
        attribute :number, :integer

        # Prefix used to differentiate editorial group for others of its class.
        attribute :prefix, :string

        # Full identifier used to identify editorial group.
        attribute :identifier, :string

        # Name of editorial group.
        attribute :name, :string
        attribute :semx_id, :string
        attribute :text, :string

        xml do
          element "subgroup"
          map_attribute "type", to: :type
          map_attribute "number", to: :number
          map_attribute "prefix", to: :prefix
          map_attribute "identifier", to: :identifier
          map_attribute "name", to: :name
          map_attribute "semx-id", to: :semx_id
          map_content to: :text
        end
      end
    end
  end
end
