# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::NoteTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::NisoSts::NonNormativeNote) do |note|
            note.id = source.id if source.id && !source.id.start_with?("_")

            transform_note_content(source, note)
          end
        end

        private

        # The note body lives on typed attributes (content holds the
        # paragraphs; ul/ol the block lists), not on mixed content —
        # walking each_mixed_content yields nothing and emits an empty
        # <non-normative-note/>. NoteBlock's dl/formula/quote have no
        # counterpart on Sts::NisoSts::NonNormativeNote and are skipped.
        def transform_note_content(source, note)
          Array(source.content).each do |para|
            note.p paragraph_transformer.transform(para)
          end
          Array(source.ul).each { |ul| note.list list_transformer.transform(ul) }
          Array(source.ol).each { |ol| note.list list_transformer.transform(ol) }
        end
      end
    end
  end
end
