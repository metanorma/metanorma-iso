# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class FrontTransformer < Base
          def transform(source)
            std_meta = build_std_meta(source)
            ModelBuilder.front(std_meta: std_meta)
          end

          def preface_sections(source)
            sections = []
            sections += build_boilerplate(source)
            sections += build_foreword(source) if source.foreword
            sections += build_introduction(source) if source.introduction
            sections
          end

          private

          def build_std_meta(source)
            title = source.formatted_title || source.title(type: "main") || source.title
            ModelBuilder.std_meta(
              doc_identifier: source.docidentifier,
              title: title,
              pub_date: source.pub_date,
              permissions: ModelBuilder.permissions(
                holder: source.copyright_holder || source.publisher || "OIML",
                year: source.copyright_year || source.pub_date
              ),
              custom_meta_group: build_custom_meta(source)
            )
          end

          def build_custom_meta(source)
            series = source.docidentifier.to_s.match(/OIML\s+([A-Z])\s/) { |m| m[1] }
            return nil unless series
            ModelBuilder.custom_meta_group(name: "oiml-doc-series", value: series)
          end

          def build_boilerplate(source)
            typed = source.typed_root
            bp = typed.boilerplate
            return [] unless bp

            sections = []
            Array(bp.copyright_statement).each do |cs|
              paragraphs = []
              cs.each_mixed_content do |inner|
                next if inner.is_a?(String)
                next unless inner.class.method_defined?(:paragraphs)
                Array(inner.paragraphs).each { |p| paragraphs << paragraph_transformer.transform(p) }
              end
              next if paragraphs.empty?
              sections << ModelBuilder.sec(title: "Copyright", paragraph: paragraphs)
            end
            Array(bp.feedback_statement).each do |fs|
              paragraphs = []
              fs.each_mixed_content do |inner|
                next if inner.is_a?(String)
                next unless inner.class.method_defined?(:paragraphs)
                Array(inner.paragraphs).each { |p| paragraphs << paragraph_transformer.transform(p) }
              end
              next if paragraphs.empty?
              sections << ModelBuilder.sec(title: "Feedback", paragraph: paragraphs)
            end
            sections
          end

          def build_foreword(source)
            content = dispatcher.dispatch_section_blocks(source.foreword)
            [ModelBuilder.sec(title: "Foreword", paragraph: content)]
          end

          def build_introduction(source)
            content = dispatcher.dispatch_section_blocks(source.introduction)
            [ModelBuilder.sec(title: "Introduction", paragraph: content)]
          end
        end
      end
    end
  end
end
