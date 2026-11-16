# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::SourcecodeTransformer < Transformer::Base
        def transform(source)
          ::Sts::NisoSts::Preformat.new do |pre|
            pre.id = source.id if source.id && !source.id.start_with?("_")
            pre.preformat_type = source.lang if source.lang

            # The literal text sits on the sourcecode's plain +content+
            # string (map_content), not on mixed content — appending it
            # explicitly keeps the preformat from serialising empty.
            pre.content = [source.content] if source.content

            inline_transformer.apply_inline_content(source, pre)
          end
        end
      end
    end
  end
end
