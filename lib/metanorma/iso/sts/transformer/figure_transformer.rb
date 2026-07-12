# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FigureTransformer < Transformer::Base
        def transform(figure)
          build_ordered(::Sts::IsoSts::Fig) do |f|
            f.id = id_for(figure)

            figure_label = label_for(figure)
            f.label figure_label if figure_label

            if figure.title
              caption = build_ordered(::Sts::IsoSts::Caption) do |c|
                inline_transformer.apply_inline_content(figure.title, c)
              end
              f.title caption
            end

            if figure.image
              images = figure.image.is_a?(Array) ? figure.image : [figure.image]
              images.each do |img|
                next unless img

                graphic = build_ordered(::Sts::IsoSts::Graphic) do |g|
                  g.xlink_href = img.src if img.src
                end
                f.graphic graphic
              end
            end
          end
        end

        private

        def label_for(figure)
          autonum = figure.autonum if figure.class.method_defined?(:autonum)
          autonum && !autonum.to_s.empty? ? ::Sts::IsoSts::Label.new(content: [autonum.to_s]) : nil
        end
      end
    end
  end
end
