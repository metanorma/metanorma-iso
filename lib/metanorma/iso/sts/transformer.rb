# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        autoload :Base, "#{__dir__}/transformer/base"
        autoload :Context, "#{__dir__}/transformer/context"
        autoload :DocumentTransformer,
                 "#{__dir__}/transformer/document_transformer"
        autoload :FrontTransformer, "#{__dir__}/transformer/front_transformer"
        autoload :IsoMetaTransformer,
                 "#{__dir__}/transformer/iso_meta_transformer"
        autoload :BodyTransformer, "#{__dir__}/transformer/body_transformer"
        autoload :BackTransformer, "#{__dir__}/transformer/back_transformer"
        autoload :SectionTransformer,
                 "#{__dir__}/transformer/section_transformer"
        autoload :ParagraphTransformer,
                 "#{__dir__}/transformer/paragraph_transformer"
        autoload :InlineTransformer, "#{__dir__}/transformer/inline_transformer"
        autoload :ListTransformer, "#{__dir__}/transformer/list_transformer"
        autoload :DefListTransformer,
                 "#{__dir__}/transformer/def_list_transformer"
        autoload :NoteTransformer, "#{__dir__}/transformer/note_transformer"
        autoload :ExampleTransformer,
                 "#{__dir__}/transformer/example_transformer"
        autoload :IdGenerator, "#{__dir__}/transformer/id_generator"
        autoload :NbspProcessor, "#{__dir__}/transformer/nbsp_processor"
        autoload :FootnoteCollector, "#{__dir__}/transformer/footnote_collector"
        autoload :ContentText, "#{__dir__}/transformer/content_text"
        autoload :BlockDispatcher, "#{__dir__}/transformer/block_dispatcher"
        autoload :TableTransformer, "#{__dir__}/transformer/table_transformer"
        autoload :FigureTransformer, "#{__dir__}/transformer/figure_transformer"
        autoload :FormulaTransformer,
                 "#{__dir__}/transformer/formula_transformer"
        autoload :SourcecodeTransformer,
                 "#{__dir__}/transformer/sourcecode_transformer"
        autoload :QuoteTransformer, "#{__dir__}/transformer/quote_transformer"
        autoload :TermTransformer, "#{__dir__}/transformer/term_transformer"
        autoload :ReferenceTransformer,
                 "#{__dir__}/transformer/reference_transformer"

        def self.transform(source)
          IdGenerator # trigger autoload
          context = Context.new(source)
          DocumentTransformer.new(context).transform(source)
        end
      end
    end
  end
end
