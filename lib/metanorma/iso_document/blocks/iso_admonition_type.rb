# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Blocks
      # Types of admonition specific to ISO/IEC.
      class IsoAdmonitionType < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :semx_id, :string
        attribute :displayorder, :integer

        def self.values
          %w[danger caution warning important safetyPrecautions]
        end

        xml do
          element "iso-admonition-type"
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
