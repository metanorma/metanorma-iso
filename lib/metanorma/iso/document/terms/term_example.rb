# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      # Example within a term entry: the shared standoc mapping, plus the
      # table, sourcecode and formula blocks ISO examples admit, kept in
      # source order.
      class TermExample < Metanorma::Standoc::Document::Terms::TermExample
        include Metanorma::Document::Components::Inline::Vocabulary

        attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :sourcecode,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :formula,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true

        attribute :figure, Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :quote, Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                  collection: true
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true
        attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true
        attribute :example,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true
        attribute :dl, Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true
        attribute :termnote, TermNote, collection: true
        attribute :termexample, TermExample, collection: true

        xml do
          mixed_content
          map_content to: :text
          Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          map_element "figure", to: :figure
          map_element "quote", to: :quote
          map_element "admonition", to: :admonition
          map_element "note", to: :note
          map_element "example", to: :example
          map_element "dl", to: :dl
          map_element "termnote", to: :termnote
          map_element "termexample", to: :termexample
          map_element "table", to: :table
          map_element "sourcecode", to: :sourcecode
          map_element "formula", to: :formula
        end
      end
    end
  end
end
