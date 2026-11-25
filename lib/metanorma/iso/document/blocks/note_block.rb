# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Blocks
      # ISO note bodies may contain ancillary blocks as well as paragraphs.
      class NoteBlock < Metanorma::Document::Components::Blocks::NoteBlock
        attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :figure, Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :example, Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        attribute :sourcecode,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true

        xml do
          map_element "table", to: :table
          map_element "figure", to: :figure
          map_element "example", to: :example
          map_element "sourcecode", to: :sourcecode
          map_element "admonition", to: :admonition
        end
      end
    end
  end
end
