# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class FigureTransformer < Base
          def transform(source_fig)
            # Figures renumber to fig_1, fig_2, … (claimed document-
            # unique, pre-registered in document order) — the mnconvert
            # numbering; source uuid ids would still validate but break
            # parity with the delivered artifact.
            fig_id = id_generator.figure_id(source_fig)

            label_text = extract_label(source_fig)
            caption_text = extract_title(source_fig)
            graphic = extract_graphic(source_fig)

            ModelBuilder.fig(id: fig_id, label: label_text, caption: ModelBuilder.caption(title: caption_text), graphic: graphic)
          end

          private

          # "Figure 1" from the presentation XML autonum attribute —
          # same pattern as TableTransformer's label.
          def extract_label(source_fig)
            return nil unless source_fig.class.method_defined?(:autonum) && source_fig.autonum

            "Figure #{source_fig.autonum}"
          end

          def extract_title(source_fig)
            return nil unless source_fig.class.method_defined?(:name) && source_fig.name

            text = RenderedTextExtractor.text_of(source_fig.name).strip
            text.empty? ? nil : text
          end

          def extract_graphic(source_fig)
            return nil unless source_fig.class.method_defined?(:image)
            images = Array(source_fig.image)
            return nil if images.empty?
            img = images.first
            href = image_href(img)
            return nil unless href

            # xlink:href is required on <graphic>; an image without a
            # usable reference cannot be emitted schema-validly.
            ModelBuilder.graphic(href: href)
          end

          # The image model stores the reference on +source+ (mapped from
          # the src= attribute); probe the known attribute names across
          # metanorma-document variants, as the OIML toolkit does.
          def image_href(img)
            %i[src source href].each do |attr|
              next unless img.class.method_defined?(attr)

              href = img.public_send(attr)
              return href if href
            end
            nil
          end
        end
      end
    end
  end
end
