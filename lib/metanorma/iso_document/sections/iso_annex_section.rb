# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Annex appearing in ISO/IEC document.
      # Inherits structure from StandardDocument::AnnexSection and overrides
      # clause/appendix/terms to use ISO-specific types.
      class IsoAnnexSection < Metanorma::StandardDocument::Sections::AnnexSection
        # Override: ISO sub-clauses are IsoClauseSection
        attribute :clause, IsoClauseSection, collection: true

        # Override: ISO appendixes are IsoClauseSection
        attribute :appendix, IsoClauseSection, collection: true

        # Override: ISO terms sections use IsoTermsSection
        attribute :terms, IsoTermsSection, collection: true

        xml do
          element "annex"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_elements(self)
        end

        json do
          map "id", to: :id
          map "number", to: :number
          map "obligation", to: :obligation
          map "title", to: :title
          map "clause", to: :clause
          map "appendix", to: :appendix
          map "paragraphs", to: :paragraphs
          map "unordered_lists", to: :unordered_lists
          map "ordered_lists", to: :ordered_lists
          map "tables", to: :tables
          map "figures", to: :figures
          map "formulas", to: :formulas
          map "examples", to: :examples
          map "notes", to: :notes
          map "admonitions", to: :admonitions
          map "sourcecode_blocks", to: :sourcecode_blocks
          map "quote_blocks", to: :quote_blocks
          map "definition_lists", to: :definition_lists
        end
      end
    end
  end
end
