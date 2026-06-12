# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Single entry point for all DOCX style resolution.
      #
      # Wraps a DocxStyleMapping and a Context to provide style lookups
      # that account for document position (annex vs body, table vs flow).
      # The adapter should only use this class — never access
      # DocxStyleMapping directly.
      #
      # Context-aware dispatch rules:
      #   - Annex context → annex heading styles, annex figure/table titles
      #   - Foreword context → ForewordText body style
      #   - Normative context → normref body style
      #   - Bibliography context → biblio body style
      #   - Note/Example context → note/example body style
      class StyleResolver
        def initialize(style_mapping, context)
          @mapping = style_mapping
          @context = context
        end

        def paragraph_style(key)
          @mapping.paragraph_style(key)
        end

        def character_style(key)
          @mapping.character_style(key)
        end

        def class_style(class_attr)
          key = normalize_class_key(class_attr)
          @mapping.paragraph_style(key)
        end

        # Return a context-appropriate body text style, or nil if no
        # contextual override applies.
        def context_body_style
          if @context.in_note
            paragraph_style(:note)
          elsif @context.in_example
            paragraph_style(:example)
          elsif @context.in_foreword
            paragraph_style(:foreword_text)
          elsif @context.in_normative
            paragraph_style(:normref) || paragraph_style(:body_text)
          elsif @context.in_bibliography
            paragraph_style(:biblio_text)
          else
            nil
          end
        end

        def heading_style(level)
          if @context.in_annex
            @mapping.annex_heading_style(level)
          else
            @mapping.heading_style(level)
          end
        end

        def figure_title_style
          if @context.in_annex
            paragraph_style(:figure_title_annex) || paragraph_style(:figure_title)
          else
            paragraph_style(:figure_title)
          end
        end

        def table_title_style
          if @context.in_annex
            paragraph_style(:table_title_annex) || paragraph_style(:table_title)
          else
            paragraph_style(:table_title)
          end
        end

        def numbering_id(key)
          @mapping.numbering_id(key)
        end

        # Depth-aware term number style: TermNum2..TermNum6 based on
        # section_depth. Terms under Heading2 get TermNum3, etc.
        def term_number_style
          paragraph_style(:term_num)
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

        CLASS_ALIASES = {
          "zzSTDTitle1" => :title,
          "zzwarning" => :warning,
          "zzCopyright" => :colophon,
        }.freeze

        def normalize_class_key(class_attr)
          str = class_attr.to_s
          if CLASS_ALIASES.key?(str)
            CLASS_ALIASES[str]
          else
            str.to_sym
          end
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
