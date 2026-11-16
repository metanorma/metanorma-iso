# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::DocumentTransformer < Transformer::Base
        def transform(source)
          source = Transformer::SourceDocument.parse(source) unless source.is_a?(Transformer::SourceDocument)

          Transformer::ModelBuilder.standard(
            lang: @context.language,
            front: Transformer::FrontTransformer.new(@context).transform(source),
            body: Transformer::BodyTransformer.new(@context).transform(source),
            back: Transformer::BackTransformer.new(@context).transform(source),
          )
        end

        def transform_to_xml(source)
          standard = transform(source)
          xml = standard.to_xml
          apply_nbsp_to_text(xml)
        end

        private

        def apply_nbsp_to_text(xml)
          Transformer::NbspProcessor.apply_to_text(xml)
        end
      end
    end
  end
end
