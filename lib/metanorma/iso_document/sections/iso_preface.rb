# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Prefatory clauses in an ISO/IEC document.
      # Extends StandardDocument::Preface with ISO-specific section types:
      #   abstract → IsoAbstractSection
      #   foreword → IsoForewordSection
      #   introduction → IsoClauseSection
      # ISO preface mandates foreword; isodoc preface is permissive.
      class IsoPreface < Metanorma::StandardDocument::Sections::Preface
        # Override: ISO uses specific section types
        attribute :abstract, IsoAbstractSection
        attribute :foreword, IsoForewordSection
        attribute :introduction, IsoClauseSection

        # Generic clauses in preface use IsoClauseSection
        attribute :clause, IsoClauseSection, collection: true

        # Acknowledgements and executivesummary use IsoClauseSection
        attribute :acknowledgements, IsoClauseSection
        attribute :executivesummary, IsoClauseSection

        xml do
          element "preface"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_elements(self)
          map_element "clause", to: :clause

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_attributes(self)
        end
      end
    end
  end
end
