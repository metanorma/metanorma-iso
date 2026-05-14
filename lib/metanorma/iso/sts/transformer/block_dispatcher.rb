# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::BlockDispatcher
        Handler = Struct.new(:source_type, :transformer_key, :transform_method,
                             :target_setter, keyword_init: true)

        def initialize(context)
          @context = context
          @transformers = {}
        end

        def dispatch(node, target)
          entry = self.class.registry[node.class]
          return false unless entry

          transformer = transformer_for(entry.transformer_key)
          result = transformer.send(entry.transform_method, node)
          target.send(entry.target_setter, result)
          true
        end

        def self.register(source_type, transformer_key:, transform_method:,
target_setter:)
          registry[source_type] = Handler.new(
            source_type: source_type,
            transformer_key: transformer_key,
            transform_method: transform_method,
            target_setter: target_setter,
          )
        end

        def self.registry
          @registry ||= build_default_registry
        end

        def self.build_default_registry
          entries = {
            # Block-level elements
            Metanorma::Document::Components::Paragraphs::ParagraphBlock =>
              %i[paragraph_transformer transform p],
            Metanorma::Document::Components::Lists::UnorderedList =>
              %i[list_transformer transform list],
            Metanorma::Document::Components::Lists::OrderedList =>
              %i[list_transformer transform list],
            Metanorma::Document::Components::Lists::DefinitionList =>
              %i[def_list_transformer transform def_list],
            Metanorma::Document::Components::Tables::TableBlock =>
              %i[table_transformer transform_wrap table_wrap],
            Metanorma::Document::Components::AncillaryBlocks::FigureBlock =>
              %i[figure_transformer transform fig],
            Metanorma::Document::Components::AncillaryBlocks::FormulaBlock =>
              %i[formula_transformer transform disp_formula],
            Metanorma::Document::Components::AncillaryBlocks::ExampleBlock =>
              %i[example_transformer transform non_normative_example],
            Metanorma::Document::Components::Blocks::NoteBlock =>
              %i[note_transformer transform non_normative_note],
            Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock =>
              %i[sourcecode_transformer transform preformat],
            Metanorma::Document::Components::MultiParagraph::QuoteBlock =>
              %i[quote_transformer transform disp_quote],
            # Section-level elements
            Metanorma::IsoDocument::Sections::IsoClauseSection =>
              %i[section_transformer transform sec],
            Metanorma::IsoDocument::Sections::IsoTermsSection =>
              %i[term_transformer transform_section term_sec],
            Metanorma::IsoDocument::Sections::IsoAnnexSection =>
              %i[section_transformer transform_annex sec],
            Metanorma::StandardDocument::Sections::StandardReferencesSection =>
              %i[reference_transformer transform_list ref_list],
          }

          entries.each_with_object({}) do |(source_type, (key, method, setter)), map|
            map[source_type] = Handler.new(
              source_type: source_type,
              transformer_key: key,
              transform_method: method,
              target_setter: setter,
            )
          end
        end

        private

        def transformer_for(key)
          @transformers[key] ||= TRANSFORMER_MAP.fetch(key).new(@context)
        end

        TRANSFORMER_MAP = {
          paragraph_transformer: Transformer::ParagraphTransformer,
          list_transformer: Transformer::ListTransformer,
          def_list_transformer: Transformer::DefListTransformer,
          table_transformer: Transformer::TableTransformer,
          figure_transformer: Transformer::FigureTransformer,
          formula_transformer: Transformer::FormulaTransformer,
          example_transformer: Transformer::ExampleTransformer,
          note_transformer: Transformer::NoteTransformer,
          sourcecode_transformer: Transformer::SourcecodeTransformer,
          quote_transformer: Transformer::QuoteTransformer,
          section_transformer: Transformer::SectionTransformer,
          term_transformer: Transformer::TermTransformer,
          reference_transformer: Transformer::ReferenceTransformer,
        }.freeze
      end
    end
  end
end
