# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      # Example within a term entry: the shared standoc mapping, plus the
      # table, sourcecode and formula blocks ISO examples admit, kept in
      # source order.
      class TermExample < Metanorma::Standoc::Document::Terms::TermExample
        attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :sourcecode,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :formula,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true

        xml do
          ordered
          map_element "table", to: :table
          map_element "sourcecode", to: :sourcecode
          map_element "formula", to: :formula
        end
      end
    end
  end
end
