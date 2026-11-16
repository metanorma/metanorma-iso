# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Sections
      # Foreword section of an ISO/IEC document.
      # Extends ContentSection (blocks + optional subsections) but maps to
      # the "foreword" element. ISO foreword typically has no subsections.
      class IsoForewordSection < Metanorma::Standoc::Document::Sections::ContentSection
        xml do
          element "foreword"
          ordered

          Metanorma::Standoc::Document::SectionXmlMapping.apply_content_section_attributes(self)
          Metanorma::Standoc::Document::SectionXmlMapping.apply_content_section_elements(self)
        end

        json do
          map "id", to: :id
          map "title", to: :title
          map "paragraphs", to: :paragraphs
          map "unordered_lists", to: :unordered_lists
          map "ordered_lists", to: :ordered_lists
          map "tables", to: :tables
          map "figures", to: :figures
          map "formulas", to: :formulas
          map "examples", to: :examples
          map "notes", to: :notes
        end
      end
    end
  end
end
