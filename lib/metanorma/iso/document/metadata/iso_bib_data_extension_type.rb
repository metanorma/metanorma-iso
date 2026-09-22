# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      class IsoBibDataExtensionType < Lutaml::Model::Serializable
        attribute :horizontal, :boolean
        attribute :editorial_group, IsoProjectGroup
        attribute :stage_name, :string
        attribute :category, :string
        attribute :updates_document_type, :string
        attribute :semx_id, :string
        attribute :doctype, DoctypeElement, collection: true
        attribute :flavor, :string
        attribute :ics, Ics, collection: true
        attribute :structuredidentifier, StructuredIdentifier
        attribute :stagename, StagenameElement
        attribute :subdoctype, :string

        xml do
          element "ext"
          map_attribute "horizontal", to: :horizontal
          map_element "editorial-group", to: :editorial_group
          map_attribute "stage-name", to: :stage_name
          map_attribute "category", to: :category
          map_attribute "semx-id", to: :semx_id
          map_element "doctype", to: :doctype
          map_element "flavor", to: :flavor
          map_element "ics", to: :ics
          map_element "structuredidentifier", to: :structuredidentifier
          map_element "stagename", to: :stagename
          map_element "updates-document-type", to: :updates_document_type
          map_element "subdoctype", to: :subdoctype
        end
      end
    end
  end
end
