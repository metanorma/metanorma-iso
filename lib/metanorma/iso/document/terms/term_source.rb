# frozen_string_literal: true

Metanorma::Iso::Document::Terms::TermSource =
  Metanorma::Document::Components::ReferenceElements::SourceElement

module Metanorma
  module Iso::Document
    module Terms
      class TermsourceElement < Metanorma::Document::Components::ReferenceElements::SourceElement
        xml do
          element "termsource"
          map_attribute "id", to: :id
          map_attribute "status", to: :status
          map_attribute "type", to: :type
          map_element "origin", to: :origin
          map_element "modification", to: :modification
        end
      end
    end
  end
end
