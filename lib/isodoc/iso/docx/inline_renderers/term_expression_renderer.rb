# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a TermExpression by walking its +name+ children in
        # order. Each name is dispatched through the parent InlineRenderer.
        class TermExpressionRenderer
          include Base

          def render(element, para)
            Array(element.name).each { |n| parent.render(n, para) }
          end
        end
      end
    end
  end
end
