# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Main body of ISO/IEC document.
      # Extends StandardDocument::Sections with ISO strict ordering:
      #   (note | admonition)*, clause, (term-clause | terms)?, definitions?,
      #   (clause | term-clause | terms)+
      class IsoSections < Metanorma::StandardDocument::Sections::Sections
        # Notes applicable to the entire document (appearing before clauses)
        attribute :note,
                  Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true

        # Admonitions applicable to the entire document
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true

        # Override: ISO terms is singular (zero or one), uses IsoTermsSection
        attribute :terms, IsoTermsSection

        # Override: ISO definitions is singular (zero or one)
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection

        # Override: ISO clauses use IsoClauseSection
        attribute :clause, IsoClauseSection, collection: true

        # Initial paragraphs (document title repeated at start of sections)
        attribute :p,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true

        xml do
          element "sections"
          ordered

          map_element "note",         to: :note
          map_element "admonition",   to: :admonition

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_elements(self)
          map_element "p", to: :p

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_attributes(self)
        end
      end
    end
  end
end
