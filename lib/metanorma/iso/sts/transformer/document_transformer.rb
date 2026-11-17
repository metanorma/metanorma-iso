# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class DocumentTransformer < Base
          def transform(source)
            front_model = build_front(source)
            body_model = build_body(source)
            back_model = build_back(source)

            std = ModelBuilder.standard(
              lang: context.language,
              dtd_version: "1.0",
              front: front_model,
              body: body_model,
              back: back_model
            )
            std
          end

          def transform_to_xml(source)
            std = transform(source)
            xml = std.to_xml
            inject_namespaces(xml)
              .then { |x| inject_processing_meta(x) }
              .then { |x| fix_lang_attribute(x) }
              .then { |x| apply_nbsp(x) }
          end

          private

          # NBSP typography between reference markers and numbers
          # ("ISO 8601", "Table 3") — text nodes only, never attributes.
          def apply_nbsp(xml)
            Transformer::NbspProcessor.apply_to_text(xml)
          end

          def build_front(source)
            return nil unless source.has_metadata?
            front_transformer.transform(source)
          end

          def build_body(source)
            BodyTransformer.new(context).transform(source)
          end

          def build_back(source)
            return nil unless source.has_back?
            BackTransformer.new(context).transform(source)
          end

          def inject_namespaces(xml)
            Metanorma::Iso::Sts.inject_namespaces(xml)
          end

          def inject_processing_meta(xml)
            Metanorma::Iso::Sts.inject_processing_meta(xml)
          end

          def fix_lang_attribute(xml)
            xml.gsub(/\slang="([a-z-]+)"/, ' xml:lang="\\1"')
          end
        end
      end
    end
  end
end
