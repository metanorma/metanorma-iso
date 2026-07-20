# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      class ScriptElement < Lutaml::Model::Serializable
        attribute :current, :string
        attribute :value, :string

        xml do
          element "script"
          map_attribute "current", to: :current
          map_content to: :value
        end
      end
    end
  end
end
