# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Mixed-content fallback: walks an element's children in
        # document order, dispatching each child back through the
        # InlineRenderer. Used for ParagraphBlock, FmtTitle, FmtName,
        # VariantTitle, and any element whose children are inline
        # formatting elements.
        class MixedInlineFallbackRenderer
          include Base

          def render(element, para)
            parent.render_mixed_inline_fallback(element, para)
          end
        end
      end
    end
  end
end
