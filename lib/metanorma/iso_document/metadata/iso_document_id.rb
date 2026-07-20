# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Representation of the identifier for an ISO/IEC document, giving its individual semantic components.
      class IsoDocumentId < Lutaml::Model::Serializable
        # N-numbers assigned to the document by technical committees.
        attribute :tc_document_number, :integer, collection: true

        # Numerical component uniquely identifying the document.
        attribute :project_number, :integer

        # Representation in the identifier of the document part, if this is a document part.
        attribute :part_number, :integer

        # Representation in the identifier of the document subpart, if this is a document subpart.
        # Only applicable to IEC documents.
        attribute :subpart_number, :integer

        # Representation in the identifier of the type of document amendment, if this is a document amendment.
        attribute :amendment_number, :integer

        # Representation in the identifier of the type of document technical corrigendum, if this is a
        # document technical corrigendum.
        attribute :corrigendum_number, :integer

        # Year of publication of the document in its current version or edition.
        attribute :originalyear, :integer
        attribute :semx_id, :string

        xml do
          element "docidentifier"
          map_element "tc-document-number", to: :tc_document_number
          map_element "project-number", to: :project_number
          map_element "part-number", to: :part_number
          map_element "subpart-number", to: :subpart_number
          map_element "amendment-number", to: :amendment_number
          map_element "corrigendum-number", to: :corrigendum_number
          map_element "originalyear", to: :originalyear
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
