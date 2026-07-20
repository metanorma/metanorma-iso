# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      class IsoTerm < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :anchor, :string
        attribute :term_number, Metanorma::Document::Components::Inline::FmtNameElement
        attribute :preferred, TermDesignation, collection: true
        attribute :admitted, TermDesignation, collection: true
        attribute :deprecates, TermDesignation, collection: true
        attribute :domain, TermDomainElement
        attribute :definition, TermDefinition, collection: true
        attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :source, TermSource, collection: true
        attribute :termsource, TermsourceElement, collection: true
        attribute :termnote, TermNote, collection: true
        attribute :termexample, TermExample, collection: true
        attribute :note, :string, collection: true
        attribute :admonition, Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true
        attribute :term, IsoTerm, collection: true
        attribute :related, Metanorma::StandardDocument::Terms::RelatedTerm,
                  collection: true
        attribute :semx_id, :string
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
        attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
        attribute :fmt_preferred,
                  Metanorma::Document::Components::Inline::FmtPreferredElement, collection: true
        attribute :fmt_admitted,
                  Metanorma::Document::Components::Inline::FmtAdmittedElement, collection: true
        attribute :fmt_definition, Metanorma::Document::Components::Inline::FmtDefinitionElement
        attribute :fmt_termsource,
                  Metanorma::Document::Components::Inline::FmtTermsourceElement, collection: true
        attribute :fmt_deprecates, Metanorma::Document::Components::Inline::FmtPreferredElement

        xml do
          element "term"
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "semx-id", to: :semx_id
          map_element "name", to: :term_number
          map_element "preferred", to: :preferred
          map_element "admitted", to: :admitted
          map_element "deprecates", to: :deprecates
          map_element "domain", to: :domain
          map_element "p", to: :p
          map_element "definition", to: :definition
          map_element "termnote", to: :termnote
          map_element "termexample", to: :termexample
          map_element "source", to: :source
          map_element "termsource", to: :termsource
          map_element "note", to: :note
          map_element "admonition", to: :admonition
          map_element "term", to: :term
          map_element "related", to: :related
          map_element "fmt-name", to: :fmt_name
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "fmt-preferred", to: :fmt_preferred
          map_element "fmt-admitted", to: :fmt_admitted
          map_element "fmt-definition", to: :fmt_definition
          map_element "fmt-termsource", to: :fmt_termsource
          map_element "fmt-deprecates", to: :fmt_deprecates
        end
      end
    end
  end
end
