# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders an inline <image> as a Word drawing run embedded in
        # the paragraph. Data-URI sources are extracted to a Tempfile;
        # missing sources fall back to the alt text or "[Image]".
        class ImageRenderer
          include Base

          def render(element, para)
            src = element.source
            return unless src

            width = parent.parse_dimension(element.width)
            height = parent.parse_dimension(element.height)
            alt = element.alt

            begin
              path = resolve_path(src)
              unless path
                para << (alt || "[Image]")
                return
              end

              run = Uniword::Builder::ImageBuilder.create_run(
                doc, path,
                width: width, height: height,
                alt_text: alt
              )
              para << run
            rescue StandardError
              para << (alt || "[Image]")
            end
          end

          private

          def resolve_path(src)
            if src.start_with?("data:")
              parent.extract_data_uri_to_tempfile(src)
            elsif File.exist?(src)
              src
            end
          end
        end
      end
    end
  end
end
