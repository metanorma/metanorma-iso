# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a block quote as a single paragraph with Disp-quotep
        # style. Era C's Disp-quotep style handles indentation; no manual
        # indent is required (manual indents fight the style and cause
        # inconsistent layout).
        class QuoteRenderer
          include Base

          def render(quote, doc)
            para = build_paragraph(:quote)
            @inline_renderer.render(quote, para)
            doc << para
          end
        end
      end
    end
  end
end
