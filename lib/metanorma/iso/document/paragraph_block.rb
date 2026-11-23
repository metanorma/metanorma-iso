# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # ISO paragraphs can contain termnotes emitted by the DOCX compatibility path.
    class ParagraphBlock < Metanorma::Document::Components::Paragraphs::ParagraphBlock
      attribute :termnote, Terms::TermNote, collection: true

      xml do
        map_element "termnote", to: :termnote
      end
    end
  end
end
