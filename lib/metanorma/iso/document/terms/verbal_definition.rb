# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      # Verbal definition of a term, containing paragraphs.
      class VerbalDefinition < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :semx_id, :string
        attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                  collection: true
        attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
        attribute :formula,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true
        attribute :figure,
                  Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :table,
                  Metanorma::Document::Components::Tables::TableBlock,
                  collection: true

        xml do
          element "verbal-definition"
          map_attribute "id", to: :id
          map_attribute "semx-id", to: :semx_id
          map_element "p", to: :p
          map_element "ol", to: :ol
          map_element "ul", to: :ul
          map_element "dl", to: :dl
          map_element "formula", to: :formula
          map_element "figure", to: :figure
          map_element "table", to: :table
        end
      end
    end
  end
end
