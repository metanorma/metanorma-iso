# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::ExampleTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::NonNormativeExample) do |example|
            example.id = source.id if source.id && !source.id.start_with?("_")

            transform_example_content(source, example)
          end
        end

        private

        def transform_example_content(source, example)
          source.each_mixed_content do |node|
            next if node.is_a?(String)

            dispatch_block(node, example)
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
          end
        end
      end
    end
  end
end
