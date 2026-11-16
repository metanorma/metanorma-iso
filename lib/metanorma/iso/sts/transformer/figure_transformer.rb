# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FigureTransformer < Transformer::Base
        def transform(figure)
          build_ordered(::Sts::NisoSts::Figure) do |f|
            f.id = id_for(figure)

            figure_label = label_for(figure)
            f.label figure_label if figure_label

            if figure.class.method_defined?(:name) && figure.name
              caption = build_ordered(::Sts::NisoSts::Caption) do |c|
                inline_transformer.apply_inline_content(figure.name, c)
              end
              f.caption caption
            end

            if figure.image
              images = figure.image.is_a?(Array) ? figure.image : [figure.image]
              images.each do |img|
                next unless img

                href = image_href(img)
                next unless href

                # xlink:href is required on <graphic>; an image without a
                # usable reference cannot be emitted schema-validly.
                graphic = build_ordered(::Sts::NisoSts::Graphic) do |g|
                  g.href = href
                end
                f.graphic graphic
              end
            end
          end
        end

        private

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

        def label_for(figure)
          autonum = figure.autonum if figure.class.method_defined?(:autonum)
          autonum && !autonum.to_s.empty? ? ::Sts::NisoSts::Label.new(content: [autonum.to_s]) : nil
        end
      end
    end
  end
end
