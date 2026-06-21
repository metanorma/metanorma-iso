# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a block-level Image element.
        #
        # Style selection is delegated to StyleResolver, which picks:
        #   - FigureGraphic when inside a figure zone (per DIS 15926)
        #   - Dimension50/75/100 for standalone images by width ratio
        #
        # ImageRenderer is also reused by FigureRenderer as a callable
        # (#call) so figure-attached images get the correct style without
        # FigureRenderer needing file-system awareness.
        class ImageRenderer
          include Base
          include ModelUtils

          def render(image, doc)
            src = image.source
            return unless src

            path = resolve_image_source(src)
            return render_image_fallback(doc, image.alt, src) unless path

            width = parse_dimension(image.width)
            height = parse_dimension(image.height)
            para = build_paragraph(image_paragraph_style(width))
            add_run_to_paragraph(para, doc, path, width: width,
                                                   height: height,
                                                   alt_text: image.alt)
            doc << para
          rescue StandardError
            render_image_fallback(doc, image.alt, src)
          end

          alias call render

          private

          def image_paragraph_style(width)
            @resolver.image_paragraph_style(width_percentage(width))
          end

          def width_percentage(width)
            return nil unless width.is_a?(Numeric) && width.positive?
            body_width = @context.body_width
            return nil unless body_width&.positive?

            (width.to_f / body_width * 100).round
          end

          def resolve_image_source(src)
            return extract_data_uri_to_tempfile(src) if src.to_s.start_with?("data:")
            return src if File.exist?(src)

            nil
          end

          def add_run_to_paragraph(para, doc, path, width:, height:, alt_text:)
            run = Uniword::Builder::ImageBuilder.create_run(
              doc, path, width: width, height: height, alt_text: alt_text,
            )
            para << run
          end

          def render_image_fallback(doc, alt, src)
            para = build_unstyled_paragraph
            para << (alt || "[Image: #{File.basename(src.to_s)}]")
            doc << para
          end
        end
      end
    end
  end
end
