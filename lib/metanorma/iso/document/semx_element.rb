# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # Presentation notes and term definitions wrap block bodies in semx.
    class SemxElement < Metanorma::Document::Components::Inline::SemxElement
      attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                collection: true
      attribute :dl, Metanorma::Document::Components::Lists::DefinitionList,
                collection: true
      attribute :quote, Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                collection: true
      attribute :admonition,
                Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                collection: true

      xml do
        map_element "table", to: :table
        map_element "dl", to: :dl
        map_element "quote", to: :quote
        map_element "admonition", to: :admonition
      end
    end
  end
end
