# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class IsoBibliographicItem < Lutaml::Model::Serializable
        attribute :doc_identifier, DocIdentifier, collection: true
        attribute :titles, AbstractTitle, collection: TitleCollection
        attribute :type, :string
        attribute :fetched, Metanorma::Document::Relaton::DateTime
        attribute :uri, Metanorma::Document::Relaton::TypedUri, collection: true
        attribute :source, :string, collection: true
        attribute :docnumber, :string
        attribute :contributor, Metanorma::Document::Relaton::ContributionInfo,
                  collection: true
        attribute :edition, Metanorma::Document::Relaton::Edition,
                  collection: true
        attribute :version, Metanorma::Document::Relaton::VersionInfo
        attribute :note, Metanorma::Document::Relaton::TypedNote,
                  collection: true
        attribute :language, LanguageElement, collection: true
        attribute :script, ScriptElement, collection: true
        attribute :abstract, Metanorma::Document::Components::DataTypes::FormattedString,
                  collection: true
        attribute :status, IsoDocumentStatus
        attribute :copyright, Metanorma::Document::Relaton::CopyrightAssociation,
                  collection: true
        attribute :relation, Metanorma::Document::Relaton::DocumentRelation,
                  collection: true
        attribute :formattedref, Metanorma::Document::Components::DataTypes::FormattedString
        attribute :date, Metanorma::Document::Relaton::BibliographicDate,
                  collection: true
        attribute :place, :string, collection: true
        attribute :ext, IsoBibDataExtensionType
        attribute :keyword, Metanorma::Document::Relaton::KeywordType,
                  collection: true
        attribute :series, Metanorma::Document::Relaton::SeriesType,
                  collection: true
        attribute :editorialgroup, Metanorma::Standoc::Document::Metadata::EditorialGroupType
        attribute :semx_id, :string
        attribute :schema_version, :string

        xml do
          element "bibdata"
          ordered
          map_attribute "type", to: :type
          map_attribute "schema-version", to: :schema_version
          map_element "fetched", to: :fetched
          map_element "title", to: :titles
          map_element "uri", to: :uri
          map_element "link", to: :source
          map_element "docidentifier", to: :doc_identifier
          map_element "docnumber", to: :docnumber
          map_element "contributor", to: :contributor
          map_element "edition", to: :edition
          map_element "version", to: :version
          map_element "note", to: :note
          map_element "language", to: :language
          map_element "script", to: :script
          map_element "abstract", to: :abstract
          map_element "status", to: :status
          map_element "copyright", to: :copyright
          map_element "relation", to: :relation
          map_element "formattedref", to: :formattedref
          map_element "date", to: :date
          map_element "place", to: :place
          map_element "ext", to: :ext
          map_element "keyword", to: :keyword
          map_element "series", to: :series
          map_element "editorial-group", to: :editorialgroup
          map_attribute "semx-id", to: :semx_id
        end

        json do
          map "doc_identifier", to: :doc_identifier
          map "titles", to: :titles
          map "type", to: :type
          map "status", to: :status
          map "source", to: :source
          map "abstract", to: :abstract
          map "ext", to: :ext
        end

        def title_for(language = "en")
          return nil unless titles

          if titles.is_a?(TitleCollection)
            titles.for_language(language)
          elsif titles.is_a?(Array)
            titles.find do |t|
              lang = safe_attr(t, :language) || safe_attr(t, :lang)
              lang == language
            end
          end
        end

        def title
          @title ||= title_for("en")
        end
      end
    end
  end
end
