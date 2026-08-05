# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # No-op renderer for model nodes whose presence has no DOCX side
        # effect at the block level (e.g., a standalone Bookmark anchor
        # that has already been emitted inline by InlineRenderer).
        class NullRenderer
          def render(_node, _doc)
            nil
          end
        end
      end
    end
  end
end
