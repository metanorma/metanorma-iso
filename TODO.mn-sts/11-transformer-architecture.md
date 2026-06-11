# 11 - Phase 2: Transformer Architecture

## Module Layout

```
lib/metanorma/iso/sts/
├── transformer.rb                    # Entry point: Transformer.transform(doc)
├── transformer/
│   ├── base.rb                       # Abstract base class
│   ├── registry.rb                   # Type → Transformer class registry
│   ├── context.rb                    # Shared transformation context (ID map, counters, etc.)
│   │
│   ├── document_transformer.rb       # Root → Sts::IsoSts::Standard
│   ├── front_transformer.rb          # bibdata → Sts::IsoSts::Front
│   ├── iso_meta_transformer.rb       # bibdata → iso-meta
│   ├── body_transformer.rb           # sections → Sts::IsoSts::Body
│   ├── back_transformer.rb           # annex + bibliography → Sts::IsoSts::Back
│   │
│   ├── section_transformer.rb        # IsoClauseSection → Sts::IsoSts::Sec
│   ├── terms_section_transformer.rb  # IsoTermsSection → Sts::IsoSts::TermSec
│   ├── norm_refs_transformer.rb      # references[normative] → Sts::IsoSts::RefList
│   ├── annex_transformer.rb          # IsoAnnexSection → Sts::IsoSts::App
│   ├── bibliography_transformer.rb   # bibliography → Sts::IsoSts::RefList
│   │
│   ├── block_transformer.rb          # Base for block-level elements
│   ├── paragraph_transformer.rb      # p → Sts::IsoSts::Paragraph
│   ├── list_transformer.rb           # ul/ol → Sts::IsoSts::List
│   ├── def_list_transformer.rb       # dl → Sts::IsoSts::DefList
│   ├── table_transformer.rb          # table → Sts::IsoSts::TableWrap
│   ├── figure_transformer.rb         # figure → Sts::IsoSts::Fig
│   ├── formula_transformer.rb        # formula → Sts::IsoSts::DispFormula
│   ├── note_transformer.rb           # note → Sts::IsoSts::NonNormativeNote
│   ├── example_transformer.rb        # example → Sts::IsoSts::NonNormativeExample
│   ├── sourcecode_transformer.rb     # sourcecode → Sts::IsoSts::Preformat
│   ├── quote_transformer.rb          # quote → Sts::NisoSts::DispQuote
│   │
│   ├── inline_transformer.rb         # Dispatches inline element transforms
│   ├── cross_ref_transformer.rb      # xref → Sts::IsoSts::Xref / TbxIsoTml::Xref
│   ├── bib_ref_transformer.rb        # eref → Sts::IsoSts::Std
│   ├── term_ref_transformer.rb       # concept → tbx:entailedTerm
│   ├── footnote_transformer.rb       # fn → Sts::IsoSts::Fn
│   │
│   ├── terminology_transformer.rb    # IsoTerm → tbx:termEntry + tig
│   │
│   ├── id_generator.rb              # ISO/IEC ID scheme generation rules
│   ├── footnote_collector.rb        # Deduplication and fn-group assembly
│   └── nbsp_processor.rb            # Non-breaking space insertion rules
```

## Base Class Design

```ruby
module Metanorma
  module Iso
    module Sts
      class Transformer::Base
        def initialize(context)
          @context = context
        end

        # Subclasses override to transform one source object to one target object
        def transform(source)
          raise NotImplementedError
        end

        # Registry lookup: delegate to the appropriate transformer for a given source
        def transform_with_registry(source)
          klass = Registry.transformer_for(source)
          klass.new(@context).transform(source)
        end

        private

        # Forward frequently-used context methods
        def id_for(source) = @context.id_generator.id_for(source)
        def section_number_for(source) = @context.section_number_for(source)
      end
    end
  end
end
```

## Context Object

```ruby
module Metanorma
  module Iso
    module Sts
      class Transformer::Context
        attr_reader :source_document, :id_generator, :footnote_collector,
                    :organization_type, :output_format

        def initialize(source_document, organization_type: :iso, output_format: :niso)
          @source_document = source_document
          @organization_type = organization_type
          @output_format = output_format
          @id_generator = IdGenerator.new(self)
          @footnote_collector = FootnoteCollector.new
        end

        def language = @source_document.bibdata.language
        def script = @source_document.bibdata.script
      end
    end
  end
end
```

## Registry (Open-Closed Principle)

```ruby
module Metanorma
  module Iso
    module Sts
      class Transformer::Registry
        @mapping = {}

        class << self
          def register(source_class, transformer_class)
            @mapping[source_class] = transformer_class
          end

          def transformer_for(source)
            @mapping[source.class] || raise("No transformer registered for #{source.class}")
          end
        end
      end
    end
  end
end
```

Each transformer self-registers:
```ruby
class ParagraphTransformer < Base
  Registry.register(Metanorma::Document::Components::Paragraphs::ParagraphBlock, self)
  # ...
end
```

## Document Transformer (Orchestrator)

```ruby
module Metanorma
  module Iso
    module Sts
      class Transformer::DocumentTransformer < Base
        def transform(source)
          context = Context.new(source)
          standard = Sts::IsoSts::Standard.new
          standard.front = FrontTransformer.new(context).transform(source)
          standard.body = BodyTransformer.new(context).transform(source)
          standard.back = BackTransformer.new(context).transform(source)
          standard.lang = context.language
          standard
        end
      end
    end
  end
end
```

## Usage

```ruby
# Parse Metanorma XML into IsoDocument::Root
mn_doc = Metanorma::IsoDocument::Root.from_xml(File.read("input.xml"))

# Transform to STS model
sts_standard = Metanorma::Iso::Sts::Transformer.transform(mn_doc)

# Serialize to STS XML
sts_xml = sts_standard.to_xml(pretty: true, declaration: true, encoding: "utf-8")
```
