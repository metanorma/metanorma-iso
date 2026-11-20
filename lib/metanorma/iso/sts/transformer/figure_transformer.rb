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

            ModelBuilder.fig(id: fig_id, label: label_text, caption: ModelBuilder.caption(title: caption_text), graphic: graphic).tap do |fig|
              key = figure_key(source_fig)
              fig.def_list = key if key
            end
          end

          private

          # The figure key (a dl inside the figure) becomes the fig's
          # def-list (Sts::NisoSts::Figure#def_list).
          def figure_key(source_fig)
            return nil unless source_fig.class.attributes.key?(:dl)

            dl = Array(source_fig.dl).first
            dl && dl_transformer.transform(dl)
          end

          # "Figure 1" from the presentation XML autonum attribute —
          # same pattern as TableTransformer's label.
          def extract_label(source_fig)
            return nil unless source_fig.autonum

            "Figure #{source_fig.autonum}"
          end

          def extract_title(source_fig)
            return nil unless source_fig.name

            text = RenderedTextExtractor.text_of(source_fig.name).strip
            text.empty? ? nil : text
          end

          def extract_graphic(source_fig)
            return nil unless source_fig.image
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
            %i[source filename].each do |attr|
              href = img.public_send(attr) if img.class.attributes.key?(attr)
              next unless href

              # Guidelines 5.10: the reference carries no asset-folder
              # prefix (ISO) and no file extension.
              return href.sub(%r{\Aimages/}, "").sub(/\.[A-Za-z0-9]+\z/, "")
            end
            nil
          end
        end
      end
    end
  end
end
