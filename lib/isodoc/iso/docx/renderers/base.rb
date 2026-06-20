# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Shared infrastructure for per-content-type renderers.
        #
        # A Renderer is a small, focused class that renders one kind of
        # model node (a Note, Figure, Table, etc.). All renderers share:
        #
        #   - @resolver       — style lookups (single source of truth)
        #   - @context        — zone tracking, counters
        #   - @inline_renderer — inline element rendering
        #   - @walker         — recursion into children (for renderers
        #                       that walk mixed content)
        #
        # Subclasses MUST implement +render(node, doc)+.
        module Base
          attr_reader :resolver, :context, :inline_renderer, :walker

          def initialize(resolver:, context:, inline_renderer:, walker:)
            @resolver = resolver
            @context = context
            @inline_renderer = inline_renderer
            @walker = walker
          end

          # Build a paragraph builder pre-styled with the given style key.
          # Returns nil for the style if the key is unmapped (caller decides
          # whether to treat that as an error).
          def build_paragraph(style_key)
            para = Uniword::Builder::ParagraphBuilder.new
            style = style_key.is_a?(Symbol) ? @resolver.paragraph_style(style_key) : style_key
            para.style = style if style
            para
          end

          # Build a paragraph builder with no style.
          def build_unstyled_paragraph
            Uniword::Builder::ParagraphBuilder.new
          end
        end
      end
    end
  end
end
