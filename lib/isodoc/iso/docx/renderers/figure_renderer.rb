# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Figure block: image (or subfigures), name (caption),
        # and Figurenote-styled notes.
        #
        # Era C template provides:
        #   - Dimension50/75/100 paragraph styles for the image (selected
        #     by image width as a percentage of body width)
        #   - Figuretitle for the caption
        #   - Figurenote for figure-attached notes
        #
        # The renderer relies on the Adapter for image source resolution
        # (data URIs, file paths) and Dimension style selection; those
        # helpers are passed in as a proc so the renderer has no
        # file-system or template-specific knowledge.
        class FigureRenderer
          include Base
          include ModelUtils

          def initialize(resolver:, context:, inline_renderer:, walker:,
                         image_renderer:)
            super(resolver: resolver, context: context,
                  inline_renderer: inline_renderer, walker: walker)
            @image_renderer = image_renderer
          end

          def render(figure, doc)
            @context.with_figure do
              render_image(figure, doc)
              render_subfigures(figure, doc)
              render_name(figure, doc)
              render_notes(figure, doc)
            end
          end

          private

          def render_image(figure, doc)
            return unless figure.class.attributes.key?(:image)
            return unless figure.image

            @image_renderer.call(figure.image, doc)
          end

          def render_subfigures(figure, doc)
            return unless figure.class.attributes.key?(:figure)
            Array(figure.figure).each { |sub| render(sub, doc) }
          end

          def render_name(figure, doc)
            name = (figure.fmt_name if figure.class.attributes.key?(:fmt_name)) ||
                   (figure.name if figure.class.attributes.key?(:name))
            return unless name

            para = build_paragraph(@resolver.figure_title_style)
            @inline_renderer.render(name, para)
            doc << para
          end

          # Era C: figure notes use the Figurenote style (not the
          # generic Noteindent used by body-level notes).
          def render_notes(figure, doc)
            return unless figure.class.attributes.key?(:note)
            Array(figure.note).each do |note|
              para = build_paragraph(:figure_note)
              @inline_renderer.render(note, para)
              doc << para
            end
          end
        end
      end
    end
  end
end
