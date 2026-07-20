# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Clause appearing in an ISO/IEC Amendment or Technical Corrigendum document.
      class IsoAmendmentClause < Lutaml::Model::Serializable
        # Block expressing a machine-readable change in a document.
        attribute :amend, Metanorma::StandardDocument::Blocks::AmendBlock
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer

        xml do
          element "clause"
          map_element "amend", to: :amend
          map_attribute "semx-id", to: :semx_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
