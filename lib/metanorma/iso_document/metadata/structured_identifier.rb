# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      class StructuredIdentifier < Lutaml::Model::Serializable
        attribute :project_number, ProjectNumber

        xml do
          element "structuredidentifier"
          map_element "project-number", to: :project_number
        end
      end
    end
  end
end
