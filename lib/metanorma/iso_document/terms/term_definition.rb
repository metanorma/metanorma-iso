# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Definition of a term.
      class TermDefinition < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :semx_id, :string
        attribute :verbal_definition, VerbalDefinition
        attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                  collection: true
        attribute :ol, "Metanorma::Document::Components::Lists::OrderedList",
                  collection: true
        attribute :ul, "Metanorma::Document::Components::Lists::UnorderedList",
                  collection: true

        xml do
          element "definition"
          map_attribute "id", to: :id
          map_attribute "semx-id", to: :semx_id
          map_element "verbal-definition", to: :verbal_definition
          map_element "p", to: :p
          map_element "ol", to: :ol
          map_element "ul", to: :ul
        end
      end
    end
  end
end
