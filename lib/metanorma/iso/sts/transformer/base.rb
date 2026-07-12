# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::Base
        attr_reader :context

        def initialize(context)
          @context = context
        end

        private

        def id_for(source)
          @context.id_generator.id_for(source)
        end

        def remap_id(source_id)
          @context.id_generator.remap(source_id)
        end

        def paragraph_transformer
          Transformer::ParagraphTransformer.new(@context)
        end

        def inline_transformer
          Transformer::InlineTransformer.new(@context)
        end

        def list_transformer
          Transformer::ListTransformer.new(@context)
        end

        def def_list_transformer
          Transformer::DefListTransformer.new(@context)
        end

        def note_transformer
          Transformer::NoteTransformer.new(@context)
        end

        def example_transformer
          Transformer::ExampleTransformer.new(@context)
        end

        def section_transformer
          Transformer::SectionTransformer.new(@context)
        end

        def table_transformer
          Transformer::TableTransformer.new(@context)
        end

        def figure_transformer
          Transformer::FigureTransformer.new(@context)
        end

        def formula_transformer
          Transformer::FormulaTransformer.new(@context)
        end

        def sourcecode_transformer
          Transformer::SourcecodeTransformer.new(@context)
        end

        def quote_transformer
          Transformer::QuoteTransformer.new(@context)
        end

        def term_transformer
          Transformer::TermTransformer.new(@context)
        end

        def reference_transformer
          Transformer::ReferenceTransformer.new(@context)
        end

        def block_dispatcher
          Transformer::BlockDispatcher.new(@context)
        end

        def build_ordered(klass)
          instance = klass.new
          instance.instance_variable_set(:@__order_tracking__, true)
          yield instance
          instance
        end

        def transform_title(source_title)
          ::Sts::IsoSts::Title.new do |t|
            if source_title.is_a?(String)
              t.content source_title
            else
              inline_transformer.apply_inline_content(source_title, t)
            end
          end
        end

        def skip_node?(node)
          case node
          when Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
               Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
               Metanorma::Document::Components::Inline::FmtTitleElement,
               Metanorma::Document::Components::Inline::FmtXrefLabelElement,
               Metanorma::Document::Components::Inline::VariantTitleElement,
               Metanorma::Document::Components::EmptyElements::PageBreakElement,
               Metanorma::Document::Components::IdElements::Bookmark,
               Metanorma::Document::Components::Inline::SemxElement
            true
          else
            false
          end
        end
      end
    end
  end
end
