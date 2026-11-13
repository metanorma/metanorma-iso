# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an empty page-break element as a DOCX page break.
        # The model node carries no content; the side effect is on +doc+.
        class PageBreakRenderer
          def render(_node, doc)
            doc.page_break
          end
        end
      end
    end
  end
end
