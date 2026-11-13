# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Designation of a term (preferred, admitted, deprecates, etc.)
      class TermDesignation < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :text, :string, collection: true
        attribute :expression, TermExpression
        attribute :source, TermSource, collection: true
        attribute :strong, "Metanorma::Document::Components::Inline::StrongRawElement",
                  collection: true
        attribute :em, "Metanorma::Document::Components::Inline::EmRawElement",
                  collection: true
        attribute :tt, "Metanorma::Document::Components::Inline::TtElement",
                  collection: true
        attribute :sup, "Metanorma::Document::Components::Inline::SupElement",
                  collection: true
        attribute :sub, "Metanorma::Document::Components::Inline::SubElement",
                  collection: true
        attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                  collection: true
        attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                  collection: true

        xml do
          map_attribute "id", to: :id
          mixed_content
          map_content to: :text
          map_element "expression", to: :expression
          map_element "source", to: :source
          map_element "strong", to: :strong
          map_element "em", to: :em
          map_element "tt", to: :tt
          map_element "sup", to: :sup
          map_element "sub", to: :sub
          map_element "span", to: :span
          map_element "semx", to: :semx
        end
      end
    end
  end
end
