# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a <figure> in a table cell through the body
          # FigureRenderer, so the image, caption, notes and key all print
          # as cell paragraphs. Anything the figure nests (a key list) goes
          # back through the cell dispatcher.
          class FigureHandler
            include Base

            def render(element, target)
              renderer.render(element, target)
            end

            private

            def renderer
              @renderer ||= begin
                options = { resolver: @resolver, context: @inline_renderer.context,
                            inline_renderer: @inline_renderer,
                            walker: Walker.new(@dispatcher) }
                image = ImageRenderer.new(**options)
                FigureRenderer.new(**options, image_renderer: image)
              end
            end
          end
        end
      end
    end
  end
end
