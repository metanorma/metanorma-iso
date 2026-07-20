# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Term collection specific to ISO/IEC documents.
      class IsoTermCollection < Lutaml::Model::Serializable
        # Term subclauses specific to ISO/IEC documents.
        attribute :terms, IsoTerm, collection: true
        attribute :semx_id, :string

        xml do
          element "terms"
          map_element "term", to: :terms
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
