# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # Presentation notes can wrap their table body in a semx slice.
    class SemxElement < Metanorma::Document::Components::Inline::SemxElement
      attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                collection: true

      xml do
        map_element "table", to: :table
      end
    end
  end
end
