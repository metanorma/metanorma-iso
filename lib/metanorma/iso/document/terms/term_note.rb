# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      # Note to a term entry.
      class TermNote < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :anchor, :string
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                  collection: true
        attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
        attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement,
                  collection: true
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
        attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement

        xml do
          element "termnote"
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "semx-id", to: :semx_id
          map_attribute "autonum", to: :autonum, render_empty: true
          map_element "name", to: :name
          map_element "p", to: :p
          map_element "ol", to: :ol
          map_element "ul", to: :ul
          map_element "dl", to: :dl
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "fmt-name", to: :fmt_name
        end
      end
    end
  end
end
