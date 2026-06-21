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
      #   - :formula     → Formuladescription body style (e.g. "where:" text)
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
        #
        # For zones that publish a "continued" variant (note, example),
        # the 2nd+ paragraphs pick up the continued style key instead of
        # the initial one. The counter is bumped by ParagraphRenderer
        # after each render via Context#mark_zone_paragraph.
        def context_body_style
          zone = @context.zone
          return nil unless zone

          if continued_zone?(zone)
            continued_key = ZONE_BODY_CONTINUED_STYLE.fetch(zone)
            @mapping.paragraph_style(continued_key)
          else
            key = ZONE_BODY_STYLE.fetch(zone, nil)
            key && @mapping.paragraph_style(key)
          end
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

        # Paragraph style for an image. Inside a figure zone, the
        # reference DOCX uses FigureGraphic for the image paragraph
        # regardless of width. Outside figures (e.g. standalone
        # <image> in body), Era C's Dimension50/75/100 styles scale
        # the image cell to body width.
        def image_paragraph_style(width_pct)
          return @mapping.paragraph_style(:figure_graphic) if @context.zone == :figure

          key = self.class.dimension_key_for(width_pct)
          @mapping.paragraph_style(key)
        end

        # Width breakpoints as a pure-function class method so tests
        # can verify dimension selection without conversion context.
        FULL_WIDTH_THRESHOLD  = 90
        MEDIUM_WIDTH_THRESHOLD = 60

        def self.dimension_key_for(pct)
          return :dimension_100 if pct.nil?
          return :dimension_100 if pct >= FULL_WIDTH_THRESHOLD
          return :dimension_75 if pct >= MEDIUM_WIDTH_THRESHOLD

          :dimension_50
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
          formula: :formula_description,
          foreword: :foreword_text,
          bibliography: :biblio_text,
          normative: :normref,
        }.freeze

        # Continuation styles for zones that split multi-paragraph bodies
        # into "initial" + "continued" variants. Only note and example
        # publish continued styleIds in Era C; other zones use the same
        # style for every paragraph.
        ZONE_BODY_CONTINUED_STYLE = {
          note: :note_indent_continued,
          example: :example_indent_continued,
        }.freeze
        private_constant :ZONE_BODY_CONTINUED_STYLE

        CLASS_ALIASES = {
          "zzSTDTitle1" => :title,
          "zzwarning" => :warning,
          "zzCopyright" => :colophon,
        }.freeze

        def normalize_class_key(class_attr)
          str = class_attr.to_s
          CLASS_ALIASES.key?(str) ? CLASS_ALIASES[str] : str.to_sym
        end

        # True when the current paragraph is the 2nd+ in a zone that
        # publishes a continued body-style variant. The first paragraph
        # in the zone returns false and uses the base style.
        def continued_zone?(zone)
          ZONE_BODY_CONTINUED_STYLE.key?(zone) &&
            @context.zone_paragraph_count(zone) > 0
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
