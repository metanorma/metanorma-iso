# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Builds header/footer text strings from a document model's bibdata.
      #
      # Examples:
      #   header_text   — "ISO/DIS 15926-100:2026(en)"
      #   copyright     — "© ISO 2026 – All rights reserved"
      #
      # Extracted from Adapter so header/footer composition is testable
      # in isolation and the Adapter stays a thin orchestrator.
      class BibDataText
        DEFAULT_COPYRIGHT_HOLDER = "ISO"
        DEFAULT_COPYRIGHT_YEAR = "2026"
        DEFAULT_LANGUAGE = "en"
        private_constant :DEFAULT_COPYRIGHT_HOLDER, :DEFAULT_COPYRIGHT_YEAR,
                         :DEFAULT_LANGUAGE

        def initialize(model)
          @model = model
        end

        def header
          bib = bibdata
          return "" unless bib

          primary = primary_identifier(bib)
          return "" unless primary

          id = extract_prop(primary, :value)
          return "" unless id

          year = copyright_year(bib)
          id_with_year = year ? "#{id}:#{year}" : id
          "#{id_with_year}(#{language_code(bib)})"
        end

        def copyright
          bib = bibdata
          return default_copyright unless bib

          year = copyright_year(bib) || DEFAULT_COPYRIGHT_YEAR
          holder = copyright_holder(bib) || DEFAULT_COPYRIGHT_HOLDER
          "© #{holder} #{year} – All rights reserved"
        end

        private

        def bibdata
          return nil unless @model.class.attributes.key?(:bibdata)

          @model.bibdata
        end

        def default_copyright
          "© #{DEFAULT_COPYRIGHT_HOLDER} #{DEFAULT_COPYRIGHT_YEAR} – All rights reserved"
        end

        def primary_identifier(bib)
          return nil unless bib.class.attributes.key?(:doc_identifier)

          identifiers = Array(bib.doc_identifier)
          identifiers.find { |d| extract_prop(d, :primary) == "true" } ||
            identifiers.first
        end

        def copyright_year(bib)
          return nil unless bib.class.attributes.key?(:copyright)

          copyrights = Array(bib.copyright)
          return nil unless copyrights.first

          first = copyrights.first
          return nil unless first.class.attributes.key?(:from)

          extract_prop(first.from)
        end

        def copyright_holder(bib)
          return nil unless bib.class.attributes.key?(:copyright)

          copyrights = Array(bib.copyright)
          return nil unless copyrights.first

          first = copyrights.first
          return nil unless first.class.attributes.key?(:owner)

          owner = Array(first.owner).first
          org = organization_from_owner(owner)
          return nil unless org
          return nil unless org.class.attributes.key?(:name)

          names = Array(org.name)
          return nil if names.empty?

          extract_prop(names.first) || DEFAULT_COPYRIGHT_HOLDER
        end

        # CopyrightOwner wraps the Organization in its +organization+
        # attribute. Older extractions returned the Organization directly,
        # so we handle both shapes for resilience.
        def organization_from_owner(owner)
          return nil unless owner

          return owner unless owner.class.attributes.key?(:organization)

          owner.organization
        end

        def language_code(bib)
          return DEFAULT_LANGUAGE unless bib.class.attributes.key?(:language)

          langs = Array(bib.language)
          lang = langs.first
          return DEFAULT_LANGUAGE unless lang

          if lang.is_a?(String)
            lang
          elsif lang.is_a?(Lutaml::Model::Serializable)
            extract_prop(lang) || DEFAULT_LANGUAGE
          else
            DEFAULT_LANGUAGE
          end
        end

        def extract_prop(node, attr = nil)
          return nil unless node
          return node.public_send(attr) if attr && node.class.attributes.key?(attr)

          if node.is_a?(String)
            node
          elsif node.is_a?(Lutaml::Model::Serializable)
            [:content, :value, :text].each do |a|
              next unless node.class.attributes.key?(a)
              val = node.public_send(a)
              return val.to_s if val.is_a?(String)
              return Array(val).first.to_s if val.is_a?(Array) && !val.empty?
            end
            node.to_s
          end
        end
      end
    end
  end
end
