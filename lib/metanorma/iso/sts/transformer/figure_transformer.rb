# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class FigureTransformer < Base
          # Returns a Figure, or an Array of Figures when the source figure
          # holds sub-figures (the callers expand arrays, see
          # BlockDispatcher#dispatch_block).
          def transform(source_fig)
            subs = sub_figures(source_fig)
            return sub_figure_models(source_fig, subs) if subs.any?

            build_fig(source_fig)
          end

          private

          def build_fig(source_fig)
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

          # A figure with sub-figures (rice Annex C.2: a/b/c, each with its
          # own image) carries no image of its own. The sub-figures' images
          # were dropped, leaving <fig> with no <graphic> (iso-gdg-8.1-2).
          # Each sub-figure is emitted as a <fig> of its own, with its own
          # label, caption and graphic. The group's caption is not emitted:
          # NISO STS <app> has no fig-group slot in the sts gem model.
          def sub_figure_models(source_fig, subs)
            own = extract_graphic(source_fig) ? [build_fig(source_fig)] : []
            models = own + subs.flat_map { |sub| as_list(transform(sub)) }
            alias_group_id(source_fig, models) if own.empty?
            models
          end

          # Model objects are not wrapped with Array(): a sub-figure may
          # itself return a list.
          def as_list(result)
            result.is_a?(Array) ? result : [result]
          end

          # Cross-references to the group (rid = the source figure's id)
          # must still resolve (iso-gdg-10.1.2-1, iso-gdg-3.4-1): the first
          # sub-figure takes the group's pre-registered fig id.
          def alias_group_id(source_fig, models)
            first = models.first
            first.id = id_generator.figure_id(source_fig) if first
          end

          def sub_figures(source_fig)
            return [] unless source_fig.class.attributes.key?(:figure)

            Array(source_fig.figure)
          end

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
              return href.delete_prefix("images/").sub(/\.[A-Za-z0-9]+\z/, "")
            end
            nil
          end
        end
      end
    end
  end
end
