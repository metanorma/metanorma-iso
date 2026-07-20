# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      class TermDomainElement < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :text, :string

        xml do
          element "domain"
          map_attribute "id", to: :id
          map_content to: :text
        end
      end
    end
  end
end
