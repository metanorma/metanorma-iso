# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::ParagraphTransformer < Transformer::Base
        def transform(source)
          ::Sts::IsoSts::Paragraph.new do |p|
            p.id = paragraph_id(source)
            p.content_type = source.type_attr if source.type_attr
            p.content_type = source.class_attr if source.class_attr && !p.content_type

            inline_transformer.apply_inline_content(source, p)
          end
        end

        private

        def paragraph_id(source)
          id = source.id
          return nil unless id && !id.start_with?("_")

          remap_id(id)
        end
      end
    end
  end
end
