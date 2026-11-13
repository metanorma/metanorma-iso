# 04 — Add `Transformer::SourceDocument`

## Why
OIML's transformer pipeline goes through a `SourceDocument` facade:

```ruby
source = Transformer::SourceDocument.parse(xml_string)
source.bibdata        # → typed IsoBibliographicItem
source.language       # → "en"
source.docidentifier  # → "ISO 17301-1:2016"
source.sections       # → ordered array of clause/terms/defs/refs
```

ISO's pipeline currently passes the raw typed root (`Metanorma::IsoDocument::Root`)
directly into transformers. That works, but every transformer reaches into
`source.bibdata`, `source.preface.foreword`, etc. by hand — there is no
single place that owns "how do I read X from the source document?" Adding
a `SourceDocument` facade matches OIML's MECE split and gives us one place
to evolve when the underlying model changes (e.g. the recent
`RawParagraph` removal would have touched one file instead of several).

## Plan
1. Create `lib/metanorma/iso/sts/transformer/source_document.rb`.
2. API mirrors OIML's:
   ```ruby
   class SourceDocument
     def self.parse(input)         # accept String, Pathname, #read
     def typed_root                # the underlying IsoDocument::Root
     def bibdata
     def language                  # default "en"
     def docidentifier             # primary id, nil if absent
     def preface
     def sections                  # ordered (clause + terms + defs + refs)
     def annexes
     def bibliography              # flattened bibitems
     def foreword / introduction / abstract
     def has_front? / has_metadata? / has_back?
   end
   ```
3. Update `Transformer.transform` to accept either a raw model (existing
   callers) or a parsed `SourceDocument` (new callers). Internal dispatch
   always uses `SourceDocument` so the accessors are unified.
4. Update `Context#initialize` to accept either; store the `SourceDocument`
   and expose `.source` (matching OIML).
5. Update `Standard` adapter (used by the metanorma processor) to wrap its
   model in a `SourceDocument` before calling `Transformer.transform`.

## Acceptance
- New file exists at `lib/metanorma/iso/sts/transformer/source_document.rb`.
- `Transformer.transform(source)` works with: (a) raw `IsoDocument::Root`,
  (b) `SourceDocument` instance, (c) XML string (parsed via `SourceDocument.parse`).
- Existing specs continue to pass (they pass a raw root).
- OIML parity: same method shape, ISO-specific extensions only where needed.
