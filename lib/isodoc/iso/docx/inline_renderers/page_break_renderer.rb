# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders an inline page-break element by appending a page-break
        # fragment to the current paragraph builder. (This is the inline
        # variant; the block-level page break is rendered by
        # Renderers::PageBreakRenderer.)
        class PageBreakRenderer
          include Base

          def render(_element, para)
            para << Uniword::Builder.page_break
          end
        end
      end
    end
  end
end
