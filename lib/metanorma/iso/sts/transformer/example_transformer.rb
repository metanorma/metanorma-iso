# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::ExampleTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::NisoSts::NonNormativeExample) do |example|
            example.id = source.id if source.id && !source.id.start_with?("_")

            transform_example_content(source, example)
          end
        end

        private

        # The example body lives on typed attributes (paragraphs holds the
        # paragraphs; ul/ol the block lists; sourcecode the literal
        # blocks), not on mixed content — walking each_mixed_content
        # yields nothing and emits an empty <non-normative-example/>.
        # ExampleBlock's dl/quote/table/figure/requirement have no
        # counterpart on Sts::NisoSts::NonNormativeExample and are
        # skipped.
        def transform_example_content(source, example)
          Array(source.paragraphs).each do |para|
            example.p paragraph_transformer.transform(para)
          end
          Array(source.ul).each { |ul| example.list list_transformer.transform(ul) }
          Array(source.ol).each { |ol| example.list list_transformer.transform(ol) }
          Array(source.sourcecode).each do |sc|
            example.preformat sourcecode_transformer.transform(sc)
          end
        end
      end
    end
  end
end
