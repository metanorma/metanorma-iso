# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # The Symbols clause also holds formulas, each with its own key list;
    # the shared standoc mapping lacks them, so they were dropped on parse.
    class DefinitionSection < Metanorma::Standoc::Document::Sections::DefinitionSection
      attribute :formula,
                Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                collection: true

      xml do
        map_element "formula", to: :formula
      end
    end
  end
end
