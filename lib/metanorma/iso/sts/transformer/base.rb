# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class Base
          attr_reader :context

          def initialize(context)
            @context = context
          end

          protected

          def source
            context.source
          end

          def id_generator
            context.id_generator
          end

          def dispatcher
            @dispatcher ||= BlockDispatcher.new(context)
          end

          def paragraph_transformer
            @paragraph_transformer ||= ParagraphTransformer.new(context)
          end

          def inline_transformer
            @inline_transformer ||= InlineTransformer.new(context)
          end

          def list_transformer
            @list_transformer ||= ListTransformer.new(context)
          end

          def table_transformer
            @table_transformer ||= TableTransformer.new(context)
          end

          def figure_transformer
            @figure_transformer ||= FigureTransformer.new(context)
          end

          def formula_transformer
            @formula_transformer ||= FormulaTransformer.new(context)
          end

          def note_transformer
            @note_transformer ||= NoteTransformer.new(context)
          end

          def requirement_transformer
            @requirement_transformer ||= RequirementTransformer.new(context)
          end

          def reference_transformer
            @reference_transformer ||= ReferenceTransformer.new(context)
          end

          def section_transformer
            @section_transformer ||= SectionTransformer.new(context)
          end

          def term_transformer
            @term_transformer ||= TermTransformer.new(context)
          end

          def dl_transformer
            @dl_transformer ||= DlTransformer.new(context)
          end

          def front_transformer
            @front_transformer ||= FrontTransformer.new(context)
          end
        end
      end
    end
  end
end
