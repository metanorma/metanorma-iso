# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class FrontTransformer < Base
          def transform(source)
            iso_meta = build_iso_meta(source)
            ModelBuilder.front(std_meta: iso_meta, sec: front_sections(source))
          end

          # The foreword and introduction are front <sec> elements
          # (Guidelines 4.3.3/4.3.4: foreword unnumbered with
          # @sec-type='foreword', introduction with @sec-type='intro').
          # Boilerplate copyright is NOT emitted as body text: it lives in
          # <std-meta>/<permissions> (Guidelines B.2.1-2).
          def front_sections(source)
            sections = []
            sections += build_foreword(source) if source.foreword
            sections += build_introduction(source) if source.introduction
            sections
          end

          private

          # ISO flavor front matter: <std-meta> per the IEC/ISO Coding
          # Guidelines ed. 2.1 §4.3.2 ISO profile (title-wrap, std-ident,
          # std-org, content-language, std-ref, doc-ref, permissions).
          def build_iso_meta(source)
            Transformer::IsoMetaTransformer.new(context).transform(source.bibdata)
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
            [ModelBuilder.sec(title: "Foreword", paragraph: content,
                              sec_type: "foreword")]
          end

          def build_introduction(source)
            content = dispatcher.dispatch_section_blocks(source.introduction)
            [ModelBuilder.sec(title: "Introduction", paragraph: content,
                              sec_type: "intro")]
          end
        end
      end
    end
  end
end
