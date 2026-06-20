# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a block-level Image element. Era C template provides
        # Dimension50/Dimension75/Dimension100 paragraph styles that
        # express image cell width as a fraction of the body column.
        #
        # ImageRenderer is also reused by FigureRenderer as a callable
        # (#call) so figure-attached images get the same Dimension style
        # logic without FigureRenderer needing file-system awareness.
        class ImageRenderer
          include Base
          include ModelUtils

          # Dimension breakpoints, expressed as image-width percentage of
          # body width. Pure-function class method so dimension selection
          # can be tested independently of conversion.
          FULL_WIDTH_THRESHOLD  = 90
          MEDIUM_WIDTH_THRESHOLD = 60

          # Returns the semantic style key (:dimension_100/75/50) for a
          # width percentage. Nil percentage (no width declared) maps to
          # the full-width style.
          def self.dimension_key_for(pct)
            return :dimension_100 if pct.nil?
            return :dimension_100 if pct >= FULL_WIDTH_THRESHOLD
            return :dimension_75 if pct >= MEDIUM_WIDTH_THRESHOLD

            :dimension_50
          end

          # Entry point for both block-level dispatch (Adapter renders an
          # Image element directly) and FigureRenderer reuse (called via
          # +#call+).
          def render(image, doc)
            src = image.source
            return unless src

            path = resolve_image_source(src)
            return render_image_fallback(doc, image.alt, src) unless path

            width = parse_dimension(image.width)
            height = parse_dimension(image.height)
            para = build_paragraph(dimension_style_for(width))
            add_run_to_paragraph(para, doc, path, width: width,
                                                   height: height,
                                                   alt_text: image.alt)
            doc << para
          rescue StandardError
            render_image_fallback(doc, image.alt, src)
          end

          alias call render

          private

          # Pick Dimension100/75/50 based on the image width relative to
          # the body column. Default (no explicit width) is full width.
          def dimension_style_for(width)
            key = self.class.dimension_key_for(width_percentage(width))
            @resolver.paragraph_style(key)
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
