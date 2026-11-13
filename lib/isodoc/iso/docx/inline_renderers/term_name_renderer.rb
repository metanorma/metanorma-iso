# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a TermName element by dispatching it back through the
        # parent InlineRenderer (it walks the same mixed-content path).
        class TermNameRenderer
          include Base

          def render(element, para)
            parent.render(element, para)
          end
        end
      end
    end
  end
end
