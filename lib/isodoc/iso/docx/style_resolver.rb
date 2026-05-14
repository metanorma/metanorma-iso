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
      class StyleResolver
        def initialize(style_mapping, context)
          @mapping = style_mapping
          @context = context
        end

        # Context-independent paragraph style lookup
        def paragraph_style(key)
          @mapping.paragraph_style(key)
        end

        def character_style(key)
          @mapping.character_style(key)
        end

        # Context-dependent heading: annex headings differ from body headings
        def heading_style(level)
          if @context.in_annex
            @mapping.annex_heading_style(level)
          else
            @mapping.heading_style(level)
          end
        end

        # Figure title differs in annex vs body
        def figure_title_style
          key = @context.in_annex ? :figure_title_annex : :figure_title
          @mapping.paragraph_style(key)
        end

        # Table title differs in annex vs body
        def table_title_style
          key = @context.in_annex ? :table_title_annex : :table_title
          @mapping.paragraph_style(key)
        end

        # Numbering definition ID for a semantic key
        def numbering_id(key)
          @mapping.numbering_id(key)
        end

        # Map a presentation XML span class attribute to a DOCX character styleId.
        # Returns nil if the class has no corresponding character style.
        def span_class_style(class_attr)
          return nil unless class_attr

          @span_class_cache ||= build_span_class_cache
          @span_class_cache[class_attr]
        end

        private

        def build_span_class_cache
          @mapping.character_styles.each_with_object({}) do |(_key, style_id), cache|
            cache[style_id] = style_id
          end
        end
      end
    end
  end
end
