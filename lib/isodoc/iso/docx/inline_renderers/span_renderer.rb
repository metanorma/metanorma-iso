# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <span class="..."> as a character-style run when the
        # class maps to a DOCX character style. Otherwise, falls back to
        # the standard mixed-inline walk.
        #
        # When stripping autonum (heading mode), spans whose class marks
        # them as autonum carriers (fmt-caption-delim, fmt-caption-label,
        # fmt-element-name) are skipped at any nesting depth.
        class SpanRenderer
          include Base

          def render(element, para)
            return if parent.stripping_autonum? &&
              parent.autonum_carrier?(element)

            style = resolver.span_class_style(element.class_attr)
            if style
              parent.render_with_char_style(element, para, style)
            else
              parent.render_mixed_inline_fallback(element, para)
            end
          end
        end
      end
    end
  end
end
