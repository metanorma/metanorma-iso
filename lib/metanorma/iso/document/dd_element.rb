# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # Standoc emits notes to entries in dd, even though the ISO schema
    # excludes them. Keep these blocks for the DOCX compatibility path.
    class DdElement < Metanorma::Document::Components::Lists::DdElement
      attribute :termnote, Terms::TermNote, collection: true
      attribute :termexample, Terms::TermExample, collection: true

      xml do
        map_element "termnote", to: :termnote
        map_element "termexample", to: :termexample
      end
    end
  end
end
