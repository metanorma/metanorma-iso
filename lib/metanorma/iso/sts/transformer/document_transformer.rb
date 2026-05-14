# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::DocumentTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::Standard) do |s|
            s.lang = @context.language
            s.front = Transformer::FrontTransformer.new(@context).transform(source)
            s.body = Transformer::BodyTransformer.new(@context).transform(source)
            s.back = Transformer::BackTransformer.new(@context).transform(source)
          end
        end

        def transform_to_xml(source)
          standard = transform(source)
          xml = standard.to_xml
          apply_nbsp_to_text(xml)
        end

        private

        def apply_nbsp_to_text(xml)
          xml.gsub(/>([^<]+)</) do |_match|
            text = Regexp.last_match(1)
            processed = Transformer::NbspProcessor.process(text)
            ">#{processed}<"
          end
        end
      end
    end
  end
end
