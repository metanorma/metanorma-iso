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
            return render_image_fallback(doc, image.alt, src) unless src

            path = resolve_image_source(src)
            return render_image_fallback(doc, image.alt, src) unless path

            render_image_with_path(image, doc, src, path)
          rescue StandardError
            render_image_fallback(doc, image.alt, src)
          end

          def render_image_with_path(image, doc, _src, path)
            width, height = resolved_image_dimensions(path, image.width, image.height)
            para = build_paragraph(image_paragraph_style(width))
            add_run_to_paragraph(para, doc, path,
                                 width: width,
                                 height: height,
                                 alt_text: image.alt)
            doc << para
          end

          alias call render

          private

          # Maximum image dimension in EMU (~4.2"). The DIS template's
          # page is 11906 twips wide (A4) with 851 twip margins on each
          # side; body width ≈ 6.5M EMU. Cap to 6M EMU so images don't
          # overflow the page.
          AUTO_MAX_DIM_EMU = 6_000_000
          private_constant :AUTO_MAX_DIM_EMU

          # PX→EMU at 96 DPI.
          PX_TO_EMU = 9525
          private_constant :PX_TO_EMU

          # Return image width/height in EMU. When source provides explicit
          # twip values, parse them; when source says "auto" (nil after
          # parsing), read the actual pixel dimensions and cap to
          # AUTO_MAX_DIM_EMU so images don't overflow the page.
          def resolved_image_dimensions(path, src_width, src_height)
            width_twips = parse_dimension(src_width)
            height_twips = parse_dimension(src_height)

            if width_twips.nil? && height_twips.nil?
              px_w, px_h = read_pixels(path)
              scale_to_fit(px_w * PX_TO_EMU, px_h * PX_TO_EMU)
            else
              [twips_to_emu(width_twips), twips_to_emu(height_twips)]
            end
          end

          def read_pixels(path)
            data = File.binread(path)

            # PNG signature is 8 bytes; IHDR chunk header is 8 bytes
            # (length + "IHDR"); width/height each 4 bytes after that,
            # at offsets 16 and 20.
            return [100, 100] unless data.start_with?("\x89PNG\r\n\x1A\n".b)

            chunk_type = data[12..15]
            return [100, 100] unless chunk_type == "IHDR"

            width = data[16..19].unpack1("N")
            height = data[20..23].unpack1("N")
            [width, height]
          rescue StandardError
            [100, 100]
          end

          def clamp_emu(emu)
            return nil unless emu&.positive?

            [emu.to_i, AUTO_MAX_DIM_EMU].min
          end

          # Scale a (width, height) EMU pair to fit inside the
          # AUTO_MAX_DIM_EMU box, preserving aspect ratio. The longer
          # dimension is scaled down to the cap; the other dimension
          # follows proportionally.
          def scale_to_fit(emu_width, emu_height)
            w = emu_width.to_i
            h = emu_height.to_i
            return [w, h] if w <= AUTO_MAX_DIM_EMU && h <= AUTO_MAX_DIM_EMU

            if w >= h
              ratio = AUTO_MAX_DIM_EMU.to_f / w
              [AUTO_MAX_DIM_EMU, (h * ratio).to_i]
            else
              ratio = AUTO_MAX_DIM_EMU.to_f / h
              [(w * ratio).to_i, AUTO_MAX_DIM_EMU]
            end
          end

          def twips_to_emu(value)
            return nil unless value

            (value.to_i * 635).to_i
          end

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
            return extract_data_uri_to_tempfile(src) if data_uri?(src)
            return src if File.exist?(src)

            nil
          end

          def data_uri?(src)
            src.to_s.start_with?("data:")
          end

          def add_run_to_paragraph(para, doc, path, attributes)
            run = Uniword::Builder::ImageBuilder.create_run(doc, path, 
                                                            **attributes)
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
