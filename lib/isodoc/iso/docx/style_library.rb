# frozen_string_literal: true

require "yaml"

module IsoDoc
  module Iso
    module Docx
      # Loads +styles.yml+ and exposes typed queries used by the validator,
      # resolver, and adapter.
      #
      # This is the single point of read for style definitions. All other
      # code asks the library "does styleId X exist as a paragraph style?"
      # rather than parsing YAML themselves.
      class StyleLibrary
        attr_reader :definitions, :template_era, :reference_doc,
                    :reference_doc_sha256, :extracted_at

        def self.load_default(template: :dis)
          path = DocxTemplates.config_dir(template) + "/styles.yml"
          from_file(path)
        end

        def self.from_file(path)
          data = YAML.load_file(path)
          sl = data.fetch("style_library")
          new(sl)
        end

        def initialize(style_library_data)
          @template_era         = style_library_data["template_era"]
          @reference_doc        = style_library_data["reference_doc"]
          @reference_doc_sha256 = style_library_data["reference_doc_sha256"]
          @extracted_at         = style_library_data["extracted_at"]
          @paragraph_styles = style_library_data.fetch("paragraph_styles", {})
          @character_styles = style_library_data.fetch("character_styles", {})
          @table_styles     = style_library_data.fetch("table_styles", {})
          @definitions = (@paragraph_styles.merge(@character_styles)
                          .merge(@table_styles))
        end

        def paragraph_style?(style_id)
          @paragraph_styles.key?(style_id.to_s)
        end

        def character_style?(style_id)
          @character_styles.key?(style_id.to_s)
        end

        def table_style?(style_id)
          @table_styles.key?(style_id.to_s)
        end

        def style?(style_id)
          @definitions.key?(style_id.to_s)
        end

        def definition_for(style_id)
          @definitions[style_id.to_s]
        end

        # True when the style has <w:numPr> in its paragraph properties —
        # i.e., the style auto-numbers and inline autonum carriers in
        # titles must be stripped.
        def auto_numbered?(style_id)
          defn = definition_for(style_id)
          return false unless defn
          ppr = defn["paragraph_properties"]
          ppr && ppr["numbering"] && ppr["numbering"]["num_id"]
        end

        def all_style_ids
          @definitions.keys
        end

        def paragraph_style_ids
          @paragraph_styles.keys
        end

        def character_style_ids
          @character_styles.keys
        end
      end
    end
  end
end
