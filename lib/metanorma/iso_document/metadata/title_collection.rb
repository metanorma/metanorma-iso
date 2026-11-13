# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Collection for title elements with consolidation mapping.
      # Groups titles by language and routes by type to typed attributes.
      #
      # Usage:
      #   bibdata.titles.items        # => All raw AbstractTitle instances
      #   bibdata.titles.per_language # => Array of IsoLocalizedTitle grouped by language
      #
      class TitleCollection < Lutaml::Model::Collection
        attribute :semx_id, :string
        instances :items, AbstractTitle
        organizes :per_language, IsoLocalizedTitle

        xml do
          root "titles"
          map_instances to: :items

          consolidate_map by: :language, to: :per_language do
            gather :language, to: :language
            dispatch_by :_type do
              route "main" => :title_full
              route "title-intro" => :title_intro
              route "intro" => :title_intro
              route "title-main" => :title_main
              route "title-part" => :title_part
              route "title-part-prefix" => :title_part_prefix
              route "title-amd" => :title_amd
              route "title-amendment-prefix" => :title_amendment_prefix
              route "title-abbrev" => :title_full
              route nil => :title_full
            end
          end
          map_attribute "semx-id", to: :semx_id
        end

        # Find the localized title for a given language
        def for_language(language = "en")
          per_language.find { |g| g.language == language }
        end
      end
    end
  end
end
