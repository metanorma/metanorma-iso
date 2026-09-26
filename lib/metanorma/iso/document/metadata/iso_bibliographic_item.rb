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

        # --- Cover identity facts -------------------------------------
        # Derived cover facts exposed to Liquid templates through the
        # model's auto-generated Drop (lutaml-model `liquid` mapping);
        # templates read cover.<key> directly off the model.

        def cover_tc_docnumbers
          doc_identifier.select { |i| i.type == "iso-tc" }.filter_map(&:value)
        end

        def cover_docnumber_undated
          doc_identifier.find { |i| i.type == "iso-undated" }&.value
        end

        def cover_stage_abbreviation
          ext&.stagename&.abbreviation.to_s
        end

        def cover_draft?
          cover_stage_abbreviation.start_with?("FD")
        end

        def cover_published_date
          published = date.find { |d| d.type == "published" }
          return nil unless published

          raw = published.on || published.text
          raw = raw.content if raw.respond_to?(:content) && raw.content
          raw = raw.to_s if raw.respond_to?(:strftime)
          raw.to_s
        end

        def cover_draftinfo
          return nil unless cover_draft? && !cover_published_date.empty?

          "(draft #{cover_published_date})"
        end

        def cover_edition_display
          content = Array(edition).first&.content.to_s
          return nil if content.empty?

          ordinals = %w[first second third fourth fifth sixth seventh
                        eighth ninth tenth]
          word = ordinals[content.to_i - 1] || "#{content}th"
          "#{word} edition".capitalize
        end

        def cover_secretariat
          subdivision_text_for("secretariat", :name)
        end

        def cover_ics
          codes = Array(ext&.ics).filter_map(&:code)
          codes.empty? ? nil : codes.join(", ")
        end

        def cover_committee_identifier
          subdivision_text_for("committee", :identifier)
        end


        def subdivision_text_for(role_description, kind)
          Array(contributor).each do |entry|
            described = Array(entry.role).any? do |role|
              Array(role.description).map(&:value).join.include?(role_description)
            end
            next unless described

            Array(entry.organization&.subdivision).each do |sub|
              if kind == :name
                name = Array(sub.name).first&.content
                name = Array(name).join
                return name unless name.empty?
              else
                value = Array(sub.identifier).first&.value.to_s
                return value unless value.empty?
              end
            end
          end
          nil
        end

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
        liquid do
          map "tc_docnumber", to: :cover_tc_docnumbers
          map "docnumber_undated", to: :cover_docnumber_undated
          map "draftinfo", to: :cover_draftinfo
          map "edition_display", to: :cover_edition_display
          map "revdate", to: :cover_published_date
          map "editorialgroup", to: :cover_committee_identifier
          map "secretariat", to: :cover_secretariat
          map "stage_abbreviation", to: :cover_stage_abbreviation
          map "ics", to: :cover_ics
        end
      end
    end
  end
end
