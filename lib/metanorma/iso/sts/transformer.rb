# frozen_string: true

# OIML Metanorma presentation XML → OIML NISO STS XML transformer.
#
# Architecture:
# - {SourceDocument}: parses input via Metanorma::Iso::Document::Root
#   (typed model, on the metanorma-document framework). Zero Nokogiri.
# - {Context}: shared state during one conversion run.
# - {ModelBuilder}: factory methods for sts-ruby model instances.
# - {DocumentTransformer}: orchestrator. Produces a Sts::NisoSts::Standard
#   root via sts-ruby models and serializes via lutaml-model.
# - Per-element transformers walk typed-model source objects and emit
#   sts-ruby model instances. Zero Nokogiri.
# - {RenderedTextExtractor}: unified text extraction from typed models.
# - {BlockDispatcher}: Open/Closed dispatch by typed model class name.
module Metanorma::Iso::Sts::Transformer
  autoload :SourceDocument, "metanorma/iso/sts/transformer/source_document"
  autoload :Standard, "metanorma/iso/sts/transformer/standard"
  autoload :Context, "metanorma/iso/sts/transformer/context"
  autoload :ModelBuilder, "metanorma/iso/sts/transformer/model_builder"
  autoload :IdGenerator, "metanorma/iso/sts/transformer/id_generator"
  autoload :FootnoteCollector, "metanorma/iso/sts/transformer/footnote_collector"
  autoload :Base, "metanorma/iso/sts/transformer/base"
  autoload :DocumentTransformer, "metanorma/iso/sts/transformer/document_transformer"
  autoload :FrontTransformer, "metanorma/iso/sts/transformer/front_transformer"
  autoload :BodyTransformer, "metanorma/iso/sts/transformer/body_transformer"
  autoload :BackTransformer, "metanorma/iso/sts/transformer/back_transformer"
  autoload :SectionTransformer, "metanorma/iso/sts/transformer/section_transformer"
  autoload :ParagraphTransformer, "metanorma/iso/sts/transformer/paragraph_transformer"
  autoload :InlineTransformer, "metanorma/iso/sts/transformer/inline_transformer"
  autoload :ListTransformer, "metanorma/iso/sts/transformer/list_transformer"
  autoload :TableTransformer, "metanorma/iso/sts/transformer/table_transformer"
  autoload :FigureTransformer, "metanorma/iso/sts/transformer/figure_transformer"
  autoload :FormulaTransformer, "metanorma/iso/sts/transformer/formula_transformer"
  autoload :NoteTransformer, "metanorma/iso/sts/transformer/note_transformer"
  autoload :RequirementTransformer, "metanorma/iso/sts/transformer/requirement_transformer"
  autoload :ProvisionIndex, "metanorma/iso/sts/transformer/provision_index"
  autoload :ReferenceTransformer, "metanorma/iso/sts/transformer/reference_transformer"
  autoload :TermTransformer, "metanorma/iso/sts/transformer/term_transformer"
  autoload :DlTransformer, "metanorma/iso/sts/transformer/dl_transformer"
  autoload :IsoMetaTransformer, "metanorma/iso/sts/transformer/iso_meta_transformer"
  autoload :ContentText, "metanorma/iso/sts/transformer/content_text"
  autoload :NbspProcessor, "metanorma/iso/sts/transformer/nbsp_processor"
  autoload :BlockDispatcher, "metanorma/iso/sts/transformer/block_dispatcher"
  autoload :RenderedTextExtractor, "metanorma/iso/sts/transformer/rendered_text_extractor"

  def self.convert(input)
    source = SourceDocument.parse(input)
    context = Context.new(source)
    DocumentTransformer.new(context).transform_to_xml(source)
  end
end
