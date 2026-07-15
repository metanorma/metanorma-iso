# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Verifies that every styleId named in +style_mapping.yml+ exists in
      # +styles.yml+, and that every abstractNumId referenced by +numbering+
      # exists in +numbering.yml+. Also verifies excluded styles are not
      # present in the mapping.
      #
      # Used:
      #   - As a build-time check (CI smoke spec).
      #   - As a startup sanity check inside StyleResolver (optional).
      #
      # Produces a list of +Defect+ value objects. Defects have +category+
      # (:unknown_paragraph, :unknown_character, :unknown_numbering,
      # :excluded_leak), +key+ (the semantic key in mapping), and
      # +style_id+ (the offending styleId).
      class StyleMappingValidator
        Defect = Struct.new(:category, :key, :style_id, :message, keyword_init: true)

        attr_reader :defects

        def initialize(mapping, library, numbering: nil)
          @mapping    = mapping
          @library    = library
          @numbering  = numbering
          @defects    = []
          validate!
        end

        def valid?
          @defects.empty?
        end

        def unknown_paragraph_styles
          @defects.select { |d| d.category == :unknown_paragraph }
        end

        def unknown_character_styles
          @defects.select { |d| d.category == :unknown_character }
        end

        def unknown_numbering
          @defects.select { |d| d.category == :unknown_numbering }
        end

        def excluded_leaks
          @defects.select { |d| d.category == :excluded_leak }
        end

        private

        def validate!
          validate_paragraph_styles
          validate_character_styles
          validate_auto_numbered_styles
          validate_numbering if @numbering
          validate_excluded
        end

        def validate_paragraph_styles
          @mapping.paragraph_styles.each do |key, style_id|
            next if style_id.nil? || style_id.to_s.empty?
            next if @library.paragraph_style?(style_id)
            @defects << Defect.new(
              category: :unknown_paragraph,
              key: key, style_id: style_id,
              message: "paragraph_styles[#{key}] -> #{style_id} is not a paragraph style in styles.yml"
            )
          end
        end

        def validate_character_styles
          @mapping.character_styles.each do |key, style_id|
            next if style_id.nil? || style_id.to_s.empty?
            next if @library.character_style?(style_id)
            @defects << Defect.new(
              category: :unknown_character,
              key: key, style_id: style_id,
              message: "character_styles[#{key}] -> #{style_id} is not a character style in styles.yml"
            )
          end
        end

        def validate_auto_numbered_styles
          (@mapping.auto_numbered_styles || []).each do |style_id|
            next if @library.style?(style_id)
            @defects << Defect.new(
              category: :unknown_paragraph,
              key: :auto_numbered_styles,
              style_id: style_id,
              message: "auto_numbered_styles lists #{style_id} which is not defined in styles.yml"
            )
          end
        end

        def validate_numbering
          @mapping.numbering.each do |key, num_id|
            next if num_id.nil?
            next if @numbering.num_id?(num_id)
            @defects << Defect.new(
              category: :unknown_numbering,
              key: key, style_id: num_id.to_s,
              message: "numbering[#{key}] -> numId=#{num_id} is not defined in numbering.yml"
            )
          end
        end

        def validate_excluded
          globs = (@mapping.excluded_styles["globs"] || [])
          return unless globs.any?
          all_mapped = (@mapping.paragraph_styles.values +
                        @mapping.character_styles.values).compact
          all_mapped.each do |leaked|
            next unless matches_any_glob?(leaked, globs)
            @defects << Defect.new(
              category: :excluded_leak,
              key: :all_mapped,
              style_id: leaked,
              message: "mapping references excluded style #{leaked}"
            )
          end
        end

        def matches_any_glob?(style_id, globs)
          globs.any? { |g| File.fnmatch(g, style_id.to_s, File::FNM_CASEFOLD) }
        end
      end
    end
  end
end
