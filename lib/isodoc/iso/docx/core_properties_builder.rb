# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Builds docProps/core.xml (Dublin Core file metadata) from the
      # document model's bibdata. Replaces template-derived values with
      # values that describe the actual document being generated.
      #
      # Properties set:
      #   dc:title          — composed English title (intro/main/part)
      #   dc:creator        — copyright holder or publisher organization
      #   cp:lastModifiedBy — same as dc:creator
      #   cp:revision       — version revision-date from bibdata (defaults to "1")
      #   dcterms:created   — first created/published/issued date from bibdata
      #   dcterms:modified  — current time
      class CorePropertiesBuilder
        W3CDTF_TYPE = "dcterms:W3CDTF"
        DEFAULT_CREATOR = "ISO"
        DEFAULT_REVISION = "1"

        def initialize(doc_model)
          @model = doc_model
          @bib = doc_model.bibdata
        end

        def build
          Uniword::Ooxml::CoreProperties.new(
            title: dc_title,
            creator: dc_creator,
            last_modified_by: dc_creator,
            revision: revision,
            created: created_property,
            modified: modified_property,
          )
        end

        private

        def dc_title
          return nil unless bib_has?(:titles)
          return nil unless @bib.titles

          localized = @bib.titles.for_language("en") ||
                      @bib.titles.for_language(nil)
          return nil unless localized

          value = localized.to_s
          value.empty? ? nil : value
        end

        def dc_creator
          org = copyright_owner_organization ||
                contributor_organization_with_role("publisher") ||
                contributor_organization_with_role("author")
          org_name(org) || DEFAULT_CREATOR
        end

        def revision
          return DEFAULT_REVISION unless bib_has?(:version)
          return DEFAULT_REVISION unless @bib.version

          value = version_string(@bib.version)
          value.to_s.empty? ? DEFAULT_REVISION : value.to_s
        end

        def created_property
          date = bibdate_of_type("created") ||
                 bibdate_of_type("published") ||
                 bibdate_of_type("issued") ||
                 bibdate_first
          build_date_property(date_value(date), Uniword::Ooxml::Types::DctermsCreatedType)
        end

        def modified_property
          build_date_property(DateTime.now, Uniword::Ooxml::Types::DctermsModifiedType)
        end

        def copyright_owner_organization
          return nil unless bib_has?(:copyright)

          copyrights = Array(@bib.copyright)
          return nil if copyrights.empty?

          first = copyrights.first
          return nil unless first.class.attributes.key?(:owner)

          owners = Array(first.owner)
          owner = owners.first
          return nil unless owner
          return nil unless owner.class.attributes.key?(:organization)

          owner.organization
        end

        def contributor_organization_with_role(role_type)
          return nil unless bib_has?(:contributor)

          match = Array(@bib.contributor).find do |c|
            next false unless c.class.attributes.key?(:role)

            Array(c.role).any? { |r| role_type_match?(r, role_type) }
          end
          return nil unless match
          return nil unless match.class.attributes.key?(:organization)

          match.organization
        end

        def role_type_match?(role, expected)
          return false unless role
          return role.type.to_s == expected if role.class.attributes.key?(:type)

          role.to_s == expected
        end

        def org_name(org)
          return nil unless org
          return nil unless org.class.attributes.key?(:name)

          names = Array(org.name)
          return nil if names.empty?

          extract_string(names.first)
        end

        def bibdate_of_type(type_name)
          return nil unless bib_has?(:date)

          Array(@bib.date).find do |d|
            d.class.attributes.key?(:type) && d.type.to_s == type_name
          end
        end

        def bibdate_first
          return nil unless bib_has?(:date)

          Array(@bib.date).first
        end

        def date_value(date)
          return nil unless date

          %i[on from].each do |attr|
            next unless date.class.attributes.key?(attr)

            val = date.public_send(attr)
            return extract_string(val) if val
          end
          nil
        end

        def version_string(version)
          return version.to_s if version.is_a?(String)
          return nil unless version.is_a?(Lutaml::Model::Serializable)

          %i[revision_date draft].each do |attr|
            next unless version.class.attributes.key?(attr)

            val = version.public_send(attr)
            return val.to_s if val.is_a?(String) && !val.empty?
          end

          nil
        end

        def build_date_property(value, type_class)
          return nil unless value

          type_class.new(value: value, type: W3CDTF_TYPE)
        end

        def extract_string(node)
          return nil unless node
          return node if node.is_a?(String)
          return node.to_s unless node.is_a?(Lutaml::Model::Serializable)

          %i[value content text].each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            return val.to_s if val.is_a?(String) && !val.empty?
            return Array(val).first.to_s if val.is_a?(Array) && !val.empty?
          end

          node.to_s
        end

        def bib_has?(attr_name)
          @bib && @bib.class.attributes.key?(attr_name)
        end
      end
    end
  end
end
