# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      # ISO notes to entries also admit ancillary block content.
      class TermNote < Metanorma::Standoc::Document::Terms::TermNote
        attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :figure, Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :example, Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        attribute :sourcecode,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :quote, Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                  collection: true
        attribute :formula,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true
        attribute :termexample,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        xml do
          ordered
          map_element "table", to: :table
          map_element "figure", to: :figure
          map_element "example", to: :example
          map_element "sourcecode", to: :sourcecode
          map_element "quote", to: :quote
          map_element "formula", to: :formula
          map_element "admonition", to: :admonition
          map_element "termexample", to: :termexample
        end
      end
    end
  end
end
