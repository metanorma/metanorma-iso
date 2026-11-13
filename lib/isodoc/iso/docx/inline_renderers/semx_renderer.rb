# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <semx element="..."> — a semantic wrapper. When the
        # element carries an "autonum" semantic and the renderer is in
        # heading-stripping mode, the element is skipped (its number
        # will be produced by the paragraph style's numPr).
        class SemxRenderer
          include Base

          def render(element, para)
            return if parent.stripping_autonum? && element.element_attr.to_s == "autonum"
            return if element.element_attr.to_s == "link"

            parent.render_mixed_inline_fallback(element, para)
          end
        end
      end
    end
  end
end
