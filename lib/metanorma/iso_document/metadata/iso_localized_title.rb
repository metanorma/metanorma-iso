# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title of ISO/IEC document for a single language.
      # Groups all title parts (title_intro, title_main, title_part, etc.) for one language.
      # This is the GroupClass used by TitleCollection's consolidation mapping.
      class IsoLocalizedTitle < Lutaml::Model::Serializable
        # Language code (en, fr, ru, etc.)
        attribute :language, :string

        # Full title (type="main")
        attribute :title_full, AbstractTitle

        # Introductory component of title.
        attribute :title_intro, AbstractTitle

        # Main component of title.
        attribute :title_main, AbstractTitle

        # Title of document part, if applicable.
        attribute :title_part, AbstractTitle

        # Title part prefix (e.g., "Part 1")
        attribute :title_part_prefix, AbstractTitle

        # Amendment description text
        attribute :title_amd, AbstractTitle

        # Amendment prefix (e.g., "AMENDMENT 1")
        attribute :title_amendment_prefix, AbstractTitle
        attribute :semx_id, :string

        # Fallback for plain titles without structured parts
        attribute :content, :string

        # Compose all parts into a single title string
        def to_s
          parts = []
          parts << title_intro&.value if title_intro
          parts << title_main&.value if title_main
          parts << title_full&.value if title_full && !title_main
          if title_part
            prefix = title_part_prefix&.value.to_s.strip
            part_val = title_part.value
            if prefix.empty?
              parts << part_val
            else
              sep = prefix.end_with?(":") ? " " : ": "
              parts << "#{prefix}#{sep}#{part_val}"
            end
          end
          return parts.join(" — ") unless parts.empty?

          content.to_s
        end
      end
    end
  end
end
