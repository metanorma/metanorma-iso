# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class FigureTransformer < Base
          def transform(source_fig)
            attrs = {}
            attrs[:id] = source_fig.id if source_fig.class.method_defined?(:id) && source_fig.id

            label_text = extract_label(source_fig)
            caption_text = extract_title(source_fig)
            graphic = extract_graphic(source_fig)

            ModelBuilder.fig(id: attrs[:id], label: label_text, caption: ModelBuilder.caption(title: caption_text), graphic: graphic)
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
            href = img.src if img.class.method_defined?(:src)
            href ||= img.href if img.class.method_defined?(:href)
            return nil unless href
            ModelBuilder.graphic(xlink_href: href)
          end
        end
      end
    end
  end
end
