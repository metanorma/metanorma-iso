# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Sections
      # Terms section specific to ISO/IEC documents.
      # Maps <terms> element with <title>, <p>, <ul>, <term> children.
      class IsoTermsSection < Lutaml::Model::Serializable
        include Metanorma::StandardDocument::PresentationAttributes

        attribute :id, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :boolean
        attribute :unnumbered, :boolean
        attribute :toc, :string
        attribute :class_attr, :string
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement
        attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :term, Metanorma::Iso::Document::Terms::IsoTerm,
                  collection: true

        # Examples directly inside terms section
        attribute :example,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        # Admonitions directly inside terms section
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true

        # Definition lists directly inside terms section
        attribute :dl,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true

        # Definitions section within terms
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection

        # Nested terms sections (terms within terms)
        attribute :terms, IsoTermsSection, collection: true

        # Nested clause sections inside terms
        attribute :clause, IsoClauseSection, collection: true

        xml do
          element "terms"

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)

          map_element "title", to: :title
          map_element "variant-title", to: :variant_title
          map_element "fmt-title", to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "p", to: :p
          map_element "ul", to: :ul
          map_element "term", to: :term
          map_element "example", to: :example
          map_element "admonition", to: :admonition
          map_element "dl", to: :dl
          map_element "definitions", to: :definitions
          map_element "terms", to: :terms
          map_element "clause", to: :clause
          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end", to: :fmt_annotation_end
        end
      end
    end
  end
end
