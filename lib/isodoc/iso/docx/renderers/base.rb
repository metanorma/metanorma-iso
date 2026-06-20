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

          # Wrap a paragraph's content with a bookmark range so Word can
          # scroll hyperlink targets to the right position. No-op when the
          # node has no +id+ attribute.
          def with_bookmark(node, para)
            name = bookmark_name(node)
            return yield unless name

            bm_id = @context.next_bookmark_id.to_s
            para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: name)
            yield
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
          end

          def bookmark_name(node)
            return nil unless node.class.attributes.key?(:id)

            node.id
          end

          # Whether a heading has no body text after autonum carriers are
          # stripped. Untitled sub-clauses (whose <fmt-title> contains
          # only the section number + delimiter) should not emit a heading
          # paragraph at all — the body paragraph follows directly.
          def heading_body_empty?(title)
            @inline_renderer.heading_body_empty?(title)
          end
        end
      end
    end
  end
end
