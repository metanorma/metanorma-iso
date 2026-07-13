# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::NoteTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::NonNormativeNote) do |note|
            note.id = source.id if source.id && !source.id.start_with?("_")

            transform_note_content(source, note)
          end
        end

        private

        def transform_note_content(source, note)
          source.each_mixed_content do |node|
            next if node.is_a?(String)

            dispatch_block(node, note)
          end
        end

        def dispatch_block(node, target)
          case node
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            target.p paragraph_transformer.transform(node)
          when Metanorma::Document::Components::Lists::UnorderedList,
               Metanorma::Document::Components::Lists::OrderedList
            target.list list_transformer.transform(node)
          when Metanorma::Document::Components::Lists::DefinitionList
            target.def_list def_list_transformer.transform(node)
          when Metanorma::Document::Components::Blocks::NoteBlock
            target.non_normative_note note_transformer.transform(node)
          when Metanorma::Document::Components::AncillaryBlocks::ExampleBlock
            target.non_normative_example example_transformer.transform(node)
          end
        end
      end
    end
  end
end
