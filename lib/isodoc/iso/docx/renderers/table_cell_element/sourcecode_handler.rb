# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a <sourcecode> inside a table cell through the body
          # SourcecodeRenderer, so the block prints once from its formatted
          # child. The paragraph handler would walk both the raw body and
          # the formatted child and print the code twice.
          class SourcecodeHandler
            include Base

            def render(element, target)
              renderer.render(element, target)
            end

            private

            def renderer
              @renderer ||= SourcecodeRenderer.new(@resolver, @inline_renderer)
            end
          end
        end
      end
    end
  end
end
