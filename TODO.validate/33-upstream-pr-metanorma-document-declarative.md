# 33 — Upstream metanorma-document: model extensions and Layer 1 declarations

## Why

The layered architecture (see ARCHITECTURE.md) assigns structural
validation to Layer 1 — the document model. metanorma-document
currently has zero Layer 1 declarations on its IsoDocument classes.
Adding them eliminates the structural regressions caused by removing
RNG and unblocks the rules noted below.

## Work items (1 PR to metanorma-document)

### Layer 1 declarations (declarative constraints on existing attributes)

| Model class | Attribute | Declaration | PR purpose |
|---|---|---|---|
| `IsoPreface` | `foreword` | `required: true` | ISO_23 absence check |
| `IsoDocumentType` | `value` | `values: [...]` | doctype enum |
| `IsoDocumentSubtype` | `value` | `values: [...]` | subtype enum |
| `IsoAdmonitionBlock` | `type` | `values: [...]` | admonition types |
| `IsoBibliographicItem` | `doc_identifier` | `collection: 1..` | primary id required |

### Model extensions (preserve data currently dropped by from_xml)

#### SubElement preserves nested sub/sup (subscript depth — TODO 28)

```ruby
# Before
class SubElement < Lutaml::Model::Serializable
  attribute :content, :string
end

# After
class SubElement < Lutaml::Model::Serializable
  attribute :content, :string
  attribute :sub, SubElement, collection: true   # recursive
  attribute :sup, SupElement, collection: true
end
```

#### FigureBlock#figure retyped as recursive FigureBlock (TODO 08)

Currently `FigureBlock#figure` is typed as `Subfigure`, which only
holds a `:value` string. Nested figures lose all their content. Either
retype as `FigureBlock` (recursive) or extend `Subfigure` to mirror
`FigureBlock`'s attribute set.

#### BibliographicDate#on accepts string sentinels (TODO 09)

Currently `:on` is typed as `DateTime`, which rejects the en-dash
sentinel used for undated references. Either retype as `:string` (and
parse to DateTime lazily) or introduce a `DateValue` union type that
preserves the sentinel alongside parsed dates.

#### StandardReferencesSection preserves nested clause/refs (TODO 16)

The RNG allows `<references>` to recursively contain `<references>`
and `<clause>` (verified at `lib/metanorma/iso/isodoc.rng`). The
model only declares bibitem/p/note/table/passthrough. Add:

```ruby
attribute :subsections, StandardReferencesSection, collection: true
attribute :clauses, ClauseSection, collection: true
```

with corresponding `map_element` calls.

## Verification

Each PR:
1. Updates the relevant IsoDocument class in metanorma-document.
2. Adds a focused spec demonstrating that from_xml preserves the
   previously-dropped data (or that Layer 1 declarations fire on
   invalid input).
3. After merge, re-vendor into metanorma-iso:
   `cp -r ../metanorma-document/lib/metanorma/iso_document/* lib/metanorma/iso_document/`
4. The corresponding Layer 3 rule in this repo can then be enabled.

## What this unblocks

- TODO 08 (subfigure) → unblocked by FigureBlock recursive retype
- TODO 09 (bibitem unpublished) → unblocked by BibliographicDate string retype
- TODO 16 (normref structure) → unblocked by StandardReferencesSection extension
- TODO 28 subscript depth → unblocked by SubElement recursive extension
- Layer 1 gating in ModelValidator → unblocked once all declarations are in place
