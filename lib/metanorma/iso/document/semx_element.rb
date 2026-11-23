# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # Presentation blocks and rich monospace content are wrapped in semx.
    class SemxElement < Metanorma::Document::Components::Inline::SemxElement
      attribute :keyword, :string, collection: true
      attribute :smallcap,
                Metanorma::Document::Components::Inline::SmallCapElement,
                collection: true
      attribute :underline,
                Metanorma::Document::Components::TextElements::UnderlineElement,
                collection: true
      attribute :strike,
                Metanorma::Document::Components::TextElements::StrikeElement,
                collection: true
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
        map_element "keyword", to: :keyword
        map_element "smallcap", to: :smallcap
        map_element "underline", to: :underline
        map_element "strike", to: :strike
        map_element "table", to: :table
        map_element "dl", to: :dl
        map_element "quote", to: :quote
        map_element "admonition", to: :admonition
      end
    end
  end
end
