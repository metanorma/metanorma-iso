# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::SourcecodeTransformer < Transformer::Base
        def transform(source)
          ::Sts::IsoSts::Preformat.new do |pre|
            pre.id = source.id if source.id && !source.id.start_with?("_")
            pre.preformat_type = source.lang if source.lang

            inline_transformer.apply_inline_content(source, pre)
          end
        end
      end
    end
  end
end
