# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # ICS (International Classification for Standards) code entry.
      class Ics < Lutaml::Model::Serializable
        attribute :code, :string
        attribute :text, :string

        xml do
          element "ics"
          map_element "code", to: :code
          map_element "text", to: :text
        end
      end
    end
  end
end
