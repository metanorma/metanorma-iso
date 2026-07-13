# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::QuoteTransformer < Transformer::Base
        def transform(quote)
          build_ordered(::Sts::NisoSts::DispQuote) do |dq|
            quote.paragraphs&.each do |para|
              dq.p paragraph_transformer.transform(para)
            end
          end
        end
      end
    end
  end
end
