# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a ParagraphBlock: applies style resolution, context-aware
        # body styling, and inline content.
        #
        # Skips body-level title paragraphs (class "zzSTDTitle" /
        # "zzSTDTitle1") because the presentation XML may inject them as
        # duplicates of the cover-page title. The adapter emits the
        # canonical middle-title paragraph itself (Adapter#render_middle_title).
        class ParagraphRenderer
          include Base

          # Class attribute pattern matching body-level title paragraphs
          # that the presentation XML injects as duplicates of the cover
          # title. The adapter emits its own zzSTDTitle paragraph from
          # bibdata; any XML-injected copy must be suppressed.
          BODY_TITLE_CLASS_PATTERN = /\AzzSTDTitle\d?\z/

          def render(paragraph, doc)
            return if body_title_paragraph?(paragraph)

            para = build_unstyled_paragraph
            apply_style(para, paragraph)
            apply_alignment(para, paragraph)
            @inline_renderer.render(paragraph, para)
            @context.mark_zone_paragraph
            doc << para
          end

          private

          def apply_style(para, paragraph)
            explicit = resolve_paragraph_style(paragraph)
            para.style = explicit if explicit
            return if explicit

            context_style = @resolver.context_body_style
            para.style = context_style if context_style
          end

          def apply_alignment(para, paragraph)
            return unless paragraph.class.attributes.key?(:alignment)
            return unless paragraph.alignment

            para.align = paragraph.alignment
          end

          def resolve_paragraph_style(node)
            cls = node.class_attr
            return @resolver.paragraph_style(cls.to_sym) if cls

            return nil unless node.class.attributes.key?(:type)

            type = node.type
            return nil unless type == "floating-title"

            depth = (node.depth || 1).to_i
            @resolver.heading_style(depth)
          end

          def body_title_paragraph?(node)
            return false unless node.class.attributes.key?(:class_attr)

            cls = node.class_attr
            return false if cls.nil?

            BODY_TITLE_CLASS_PATTERN.match?(cls.to_s)
          end
        end
      end
    end
  end
end
