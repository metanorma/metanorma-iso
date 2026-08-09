# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Sections
      # Prefatory clauses in an ISO/IEC document.
      # Corresponds to isostandard.rng:
      #   preface = element preface { abstract?, foreword, introduction? }
      #
      # This class deliberately does NOT inherit StandardDocument::Preface:
      # lutaml-model deep-duplicates a parent's XML mappings into subclasses,
      # so inheriting would keep the isodoc-level acknowledgements and
      # executivesummary mappings that the ISO grammar forbids. Attributes
      # are composed directly instead.
      #
      # The `clause` mapping is a documented extension required by real ISO
      # presentation output, which emits front-matter clauses such as
      # `<clause type="toc">` ahead of the foreword. `content` mirrors
      # `clause` for the generic preface-content consumers (e.g. the mirror
      # renderer), matching the runtime behavior of the previous inherited
      # dual mapping.
      class IsoPreface < Lutaml::Model::Serializable
        attribute :abstract, IsoAbstractSection
        attribute :foreword, IsoForewordSection, required: true
        attribute :introduction, IsoClauseSection

        # Presentation front-matter clauses (e.g. table of contents placeholder)
        attribute :clause, IsoClauseSection, collection: true
        attribute :content, Metanorma::StandardDocument::Sections::ContentSection,
                  collection: true

        # Presentation-specific attributes
        attribute :semx_id, :string
        attribute :displayorder, :integer

        xml do
          element "preface"
          ordered

          map_element "abstract",     to: :abstract
          map_element "foreword",     to: :foreword
          map_element "introduction", to: :introduction
          map_element "clause",       to: :clause
          map_element "clause",       to: :content

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_attributes(self)
        end
      end
    end
  end
end
