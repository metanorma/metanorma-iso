# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Blocks
      # ISO formulas may carry notes, which the base block does not map.
      class FormulaBlock < Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
        attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true

        xml do
          map_element "note", to: :note
        end
      end
    end
  end
end
