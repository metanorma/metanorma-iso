# TODO 003: Implement ISO Document Properties (docProps/custom.xml)

## Status: COMPLETE

## What

Generate ISO-specific custom properties (`docProps/custom.xml`) from the metanorma document model's bibdata. These 20 properties are required by ISO's publishing pipeline.

## Why

The reference DOCX has 20 custom properties that the ISO Typefi publishing pipeline reads for document identification, copyright, and classification. Without these, the ISO pipeline cannot process the document correctly.

## Architecture

### New class: `IsoDoc::Iso::Docx::DocumentProperties`

**Responsibility**: Extract metadata from the document model's bibdata and produce a `Uniword::Ooxml::CustomProperties` object with all ISO-required properties.

**Single source of truth**: All property values come from the document model (bibdata). No hardcoded values except `copyright-statement` which is always "All rights reserved" per ISO policy.

**OCP**: Adding new properties = adding a new entry to the PROPERTIES registry. No method changes needed.

```ruby
module IsoDoc
  module Iso
    module Docx
      class DocumentProperties
        # Each entry: [property_name, value_type, extractor_method]
        PROPERTIES = [
          ["intro",              :string, :title_intro],
          ["main",               :string, :title_main],
          ["compl",              :string, :title_complement],
          ["full",               :string, :title_full],
          ["proj-id",            :integer, :project_id],
          ["release-version",    :string, :release_version],
          ["ident-originator",   :string, :ident_originator],
          ["ident-doc-type",     :string, :ident_doc_type],
          ["ident-doc-number",   :integer, :ident_doc_number],
          ["ident-part-number",  :integer, :ident_part_number],
          ["ident-edition",      :integer, :ident_edition],
          ["ident-version",      :integer, :ident_version],
          ["content-language",   :string, :content_language],
          ["doc-ref",            :string, :doc_ref],
          ["comm-ref",           :string, :comm_ref],
          ["secretariat",        :string, :secretariat],
          ["copyright-statement", :string, :copyright_statement],
          ["copyright-year",     :string, :copyright_year],
          ["copyright-holder",   :string, :copyright_holder],
          ["self-uri",           :string, :self_uri],
        ].freeze

        def initialize(doc_model)
          @model = doc_model
        end

        def build
          properties = PROPERTIES.each_with_index.map do |(name, type, extractor), i|
            value = send(extractor)
            next unless value

            Uniword::Ooxml::CustomProperty.new(
              fmtid: "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}",
              pid: i + 2,
              name: name,
              **property_value(type, value),
            )
          end.compact

          Uniword::Ooxml::CustomProperties.new(properties: properties)
        end

        private

        def property_value(type, value)
          case type
          when :string
            { lpwstr: Uniword::Ooxml::Types::VariantTypes::VtLpwstr.new(value: value.to_s) }
          when :integer
            { i4: Uniword::Ooxml::Types::VariantTypes::VtI4.new(value: value.to_i) }
          end
        end

        # Extractors — read from @model bibdata
        def title_intro
          @model.bibdata&.title&.intro
        end

        def title_main
          @model.bibdata&.title&.main
        end

        # ... etc for all extractors
      end
    end
  end
end
```

### Integration in Adapter

In `adapter.rb`, after building the document:

```ruby
def save_document(model, output_path)
  # Set custom properties from document model
  root = doc.model
  root.custom_properties = DocumentProperties.new(doc_model).build
  Uniword::DocumentWriter.new(root).save(output_path)
end
```

### Core Properties

Also set core properties (`docProps/core.xml`):
- `dc:title` — full document title
- `dc:creator` — "ISO" (or the copyright holder)
- `dc:language` — document language

### Value Extraction

The extractor methods need to map from the metanorma document model's bibdata to the ISO property names. The exact attribute paths depend on the model structure, but generally:

| ISO Property | Model Path |
|-------------|-----------|
| intro | `bibdata.titles[intro]` or parse from `title/intro` |
| main | `bibdata.titles[main]` or parse from `title/main` |
| compl | `bibdata.titles[complement]` |
| full | `bibdata.titles[full]` |
| proj-id | `bibdata.ext.project_id` |
| release-version | derived from stage (40→"DIS", 30→"CD", etc.) |
| ident-originator | "ISO" (fixed for ISO documents) |
| ident-doc-type | "IS" for international-standard, etc. |
| ident-doc-number | `bibdata.docnumber` |
| ident-part-number | from part number in docidentifier |
| ident-edition | `bibdata.edition` |
| ident-version | version number (usually 1) |
| content-language | `bibdata.language` |
| doc-ref | `bibdata.docidentifier` primary |
| comm-ref | `bibdata.editorialgroup.committee` / SC |
| secretariat | `bibdata.editorialgroup.secretariat` |
| copyright-statement | "All rights reserved" (fixed) |
| copyright-year | `bibdata.copyright.from` |
| copyright-holder | `bibdata.copyright.holder` |
| self-uri | `bibdata.uri` or construct from parts |

## Files

- `lib/isodoc/iso/docx/document_properties.rb` — new class
- `lib/isodoc/iso/docx.rb` — add autoload for DocumentProperties
- `lib/isodoc/iso/docx/adapter.rb` — integrate in save flow

## Specs

- `spec/isodoc/docx/document_properties_spec.rb` — test each property extraction
  - Use real presentation XML fixture data for bibdata
  - Verify all 20 properties are set
  - Verify correct types (lpwstr vs i4)
  - Verify pid numbering starts at 2
