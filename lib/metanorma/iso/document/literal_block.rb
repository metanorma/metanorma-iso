# frozen_string_literal: true

module Metanorma
  module Iso::Document
    # A <pre> may carry inline markup; the base block maps only its own
    # text nodes, which drops the content of child elements.
    class LiteralBlock < Metanorma::Document::Components::AncillaryBlocks::LiteralBlock
      include Metanorma::Document::Components::Inline::Vocabulary

      xml do
        mixed_content
        map_content to: :text
        Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping
          .apply_inline_mappings(self)
      end
    end
  end
end
