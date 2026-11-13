# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Sections
      # A numbered clause in an ISO/IEC document body.
      # Extends StandardDocument::ClauseSection with ISO-specific overrides:
      #   - Recursive clauses are IsoClauseSection (not ClauseSection)
      #   - Terms sections are IsoTermsSection (not TermsSection)
      class IsoClauseSection < Metanorma::Standoc::Document::Sections::ClauseSection
        # Override: ISO sub-clauses are IsoClauseSection
        attribute :clause, IsoClauseSection, collection: true

        # Override: ISO terms sections use IsoTermsSection
        attribute :terms, IsoTermsSection, collection: true

        # Presentation XML carries the term entries of a "Terms and
        # definitions" clause as direct <clause> children (isodoc
        # flattens the <terms> wrapper); parse them so they render.
        attribute :term, Metanorma::Iso::Document::Terms::IsoTerm,
                  collection: true

        xml do
          element "clause"
          ordered

          Metanorma::Standoc::Document::SectionXmlMapping.apply_clause_attributes(self)
          Metanorma::Standoc::Document::SectionXmlMapping.apply_clause_elements(self)
          map_element "term", to: :term
        end

        json do
          map "id", to: :id
          map "type", to: :type
          map "number", to: :number
          map "title", to: :title
          map "inline_header", to: :inline_header
          map "obligation", to: :obligation
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
          map "clause", to: :clause
        end
      end
    end
  end
end
