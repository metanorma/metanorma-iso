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
        # Empty-range bookmark placement shared by the renderers and the
        # adapter's block dispatch.
        module Anchoring
          module_function

          # Name a node's bookmark carries: its +anchor+ (what xrefs
          # target) wins over its +id+.
          def name_of(node)
            attrs = node.class.attributes
            (node.anchor if attrs.key?(:anchor)) ||
              (node.id if attrs.key?(:id))
          end

          # Anchor +node+ at +para+ (builder or model) as an empty
          # bookmark ahead of the content, as Word emits it. A name
          # already bookmarked, or illegal for Word, is skipped.
          def anchor(context, node, para)
            name = name_of(node)
            return unless name && context.claim_bookmark_name(name)

            model = para.respond_to?(:model) ? para.model : para
            bm_id = context.next_bookmark_id.to_s
            model.bookmark_starts <<
              Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id,
                                                           name: name)
            model.bookmark_ends <<
              Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
          end
        end

        module Base
          include ModelUtils

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
            style = resolve_style(style_key)
            para.style = style if style
            para
          end

          def resolve_style(style_key)
            return style_key unless style_key.is_a?(Symbol)

            @resolver.paragraph_style(style_key)
          end

          # Build a paragraph builder with no style.
          def build_unstyled_paragraph
            Uniword::Builder::ParagraphBuilder.new
          end

          # Wrap a paragraph's content with a bookmark range so Word can
          # scroll hyperlink targets to the right position. No-op when the
          # node has neither +anchor+ nor +id+. Xrefs link via +target+,
          # which is the element's +anchor+, so the anchor wins over the
          # (possibly different) +id+.
          def with_bookmark(node, para, &)
            name = bookmark_name(node)
            return with_unclaimable_toc_bookmark(name, para, &) unless name && @context.claim_bookmark_name(name)

            bm_id = @context.next_bookmark_id.to_s
            para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, 
                                                                 name: name)
            with_toc_bookmark(name, para, &)
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
          end

          # Anchor +node+ (by its id/anchor) at +para+, a paragraph
          # builder or model, as an empty bookmark ahead of the content
          # (as Word emits it). Used where the paragraph is built by a
          # container renderer instead of passing through with_bookmark:
          # list items, note/example lead paragraphs, definition list
          # entries. A name already bookmarked, or illegal for Word, is
          # skipped.
          def anchor_paragraph(node, para)
            Anchoring.anchor(@context, node, para)
          end

          # Headings the table of contents lists carry a second,
          # Word-style +_Toc+ bookmark (the ToC entry's hyperlink and
          # PAGEREF target). The id bookmark stays: xrefs link to it.
          def with_toc_bookmark(name, para)
            return yield unless @context.toc_targets.include?(name)

            toc_id = @context.next_bookmark_id.to_s
            para << Uniword::Wordprocessingml::BookmarkStart.new(
              id: toc_id, name: Context.toc_bookmark_name(name),
            )
            yield
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: toc_id)
          end

          # A heading id Word cannot bookmark (over MAX_BOOKMARK_NAME)
          # still gets its +_Toc+ twin, which is always a legal name:
          # the ToC entry's hyperlink and PAGEREF point at it. The id
          # itself stays unbookmarked, so xrefs to it remain unresolved.
          def with_unclaimable_toc_bookmark(name, para, &)
            if name.to_s.length > Context::MAX_BOOKMARK_NAME
              with_toc_bookmark(name, para, &)
            else
              yield
            end
          end

          def bookmark_name(node)
            Anchoring.name_of(node)
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
