# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Single entry point for all DOCX style resolution.
      #
      # Wraps a DocxStyleMapping, a StyleLibrary (definitions), and a
      # Context to provide:
      #
      #   - paragraph_style!(key)        — strict, raises UnknownStyleError
      #   - paragraph_style_or_nil(key)  — lenient, returns nil on miss
      #   - context-aware dispatch       — based on Context#zone (enum)
      #
      # Strict variant is used when the caller requires the style to
      # exist (a missing mapping is a configuration bug).
      #
      # Context-aware dispatch rules:
      #   - :annex       → annex heading + annex figure/table titles
      #   - :foreword    → ForewordText body style
      #   - :note        → Noteindent body style
      #   - :example     → Exampleindent body style
      #   - :bibliography → BiblioText body style
      #   - :normative   → normref body style
      #   - :body        → default (nil)
      class StyleResolver
        attr_reader :mapping, :library, :context

        def initialize(style_mapping, context, library: nil)
          @mapping = style_mapping
          @context = context
          @library = library
        end

        # Strict paragraph-style lookup. Raises UnknownStyleError on miss.
        def paragraph_style!(key, role: key)
          value = @mapping.paragraph_style(key)
          return value if value
          raise UnknownStyleError.new(key, role: role, context: @context)
        end

        # Lenient lookup. Returns nil on miss.
        def paragraph_style_or_nil(key)
          @mapping.paragraph_style(key)
        end

        # Backward-compatible alias: returns nil on miss.
        def paragraph_style(key)
          @mapping.paragraph_style(key)
        end

        # Strict character-style lookup.
        def character_style!(key, role: key)
          value = @mapping.character_style(key)
          return value if value
          raise UnknownStyleError.new(key, role: role, context: @context)
        end

        def character_style_or_nil(key)
          @mapping.character_style(key)
        end

        def character_style(key)
          @mapping.character_style(key)
        end

        def class_style(class_attr)
          key = normalize_class_key(class_attr)
          @mapping.paragraph_style(key)
        end

        # Context-aware body text style. Returns nil in the default zone.
        # Single dispatch via Context#zone — no boolean chain.
        def context_body_style
          ZONE_BODY_STYLE.fetch(@context.zone, nil)&.then { |k| @mapping.paragraph_style(k) }
        end

        def heading_style(level)
          if @context.in_annex
            @mapping.annex_heading_style(level) || @mapping.heading_style(level)
          else
            @mapping.heading_style(level)
          end
        end

        def heading_style!(level)
          value = heading_style(level)
          return value if value
          raise UnknownStyleError.new(
            "heading#{level}", role: :heading_style, context: @context
          )
        end

        def figure_title_style
          key = @context.in_annex ? :figure_title_annex : :figure_title
          @mapping.paragraph_style(key)
        end

        def table_title_style
          key = @context.in_annex ? :table_title_annex : :table_title
          @mapping.paragraph_style(key)
        end

        def numbering_id(key)
          @mapping.numbering_id(key)
        end

        def numbering_id!(key)
          value = @mapping.numbering_id(key)
          return value if value
          raise UnknownStyleError.new(key, role: :numbering, context: @context)
        end

        def auto_numbered_style?(style_id)
          @mapping.auto_numbered_style?(style_id)
        end

        def term_number_style
          @mapping.paragraph_style(:term_num)
        end

        SPAN_CLASS_TO_STYLE = {
          "stdpublisher" => "stdpublisher0",
          "stddocNumber" => "stddocnumber",
          "stdyear" => "stdyear",
          "stddocTitle" => "stddoctitle",
          "stddocPartNumber" => "stddocpartnumber",
          "std_publisher" => "stdpublisher",
          "citesec" => "citesec",
          "citeapp" => "citeapp",
          "citefig" => "citefig",
          "citetbl" => "citetbl",
          "notelabel" => "notelabel",
          "termnotelabel" => "termnotelabel",
          "examplelabel" => "examplelabel",
          "stem" => "stem",
          "boldtitle" => "boldtitle",
          "nonboldtitle" => "nonboldtitle",
        }.freeze

        def span_class_style(class_attr)
          return nil unless class_attr
          SPAN_CLASS_TO_STYLE[class_attr] || build_span_class_cache[class_attr]
        end

        private

        # Single dispatch table: zone → semantic paragraph-style key.
        # MECE: each zone maps to exactly one body-style key.
        ZONE_BODY_STYLE = {
          note: :note_indent,
          example: :example_indent,
          foreword: :foreword_text,
          bibliography: :biblio_text,
          normative: :normref,
        }.freeze

        CLASS_ALIASES = {
          "zzSTDTitle1" => :title,
          "zzwarning" => :warning,
          "zzCopyright" => :colophon,
        }.freeze

        def normalize_class_key(class_attr)
          str = class_attr.to_s
          CLASS_ALIASES.key?(str) ? CLASS_ALIASES[str] : str.to_sym
        end

        def build_span_class_cache
          @mapping.character_styles.each_with_object({}) do |(_key, style_id), cache|
            cache[style_id] = style_id
          end
        end
      end
    end
  end
end
