# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Abstract base class for typed title elements.
      # Subclasses correspond to different title types in ISO XML:
      # - TitleFull: type="main"
      # - TitleIntro: type="title-intro"
      # - TitleMain: type="title-main"
      # - TitlePart: type="title-part"
      # - TitlePartPrefix: type="title-part-prefix"
      class AbstractTitle < Lutaml::Model::Serializable
        attribute :_type, :string
        attribute :language, :string
        attribute :format, :string
        attribute :value, :string
        attribute :semx_id, :string

        xml do
          map_attribute "language", to: :language
          map_attribute "type", to: :_type
          map_attribute "format", to: :format
          map_content to: :value
          map_attribute "semx-id", to: :semx_id
        end

        json do
          map "_type", to: :_type
          map "language", to: :language
          map "value", to: :value
        end
      end
    end
  end
end
