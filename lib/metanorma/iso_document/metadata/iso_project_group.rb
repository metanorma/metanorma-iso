# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Editorial groups associated with the production of an ISO/IEC document.
      class IsoProjectGroup < Lutaml::Model::Serializable
        # Technical committees.
        attribute :technical_committee, IsoSubGroup, collection: true

        # Subcommittees.
        attribute :subcommittee, IsoSubGroup, collection: true

        # Workgroups.
        attribute :workgroup, IsoSubGroup, collection: true

        # Secretariat.
        attribute :secretariat, :string
        attribute :semx_id, :string

        xml do
          element "editorial-group"
          map_element "technical-committee", to: :technical_committee
          map_element "subcommittee", to: :subcommittee
          map_element "workgroup", to: :workgroup
          map_attribute "secretariat", to: :secretariat
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
