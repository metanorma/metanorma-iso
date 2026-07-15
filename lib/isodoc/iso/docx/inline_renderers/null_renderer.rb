# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # No-op renderer for inline elements whose presence has no DOCX
        # side effect:
        #   - <fmt-xref-label> (already emitted by the FmtXrefRenderer
        #     via its child runs)
        #   - <math> inside an inline stem (the parent stem handler
        #     already renders the equation as text via StemRenderer)
        class NullRenderer
          include Base

          def render(_element, _para)
            nil
          end
        end
      end
    end
  end
end
