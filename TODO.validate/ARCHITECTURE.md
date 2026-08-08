# Validation Architecture

## Layered design

Validation is organized as four layers, each with a single
responsibility (MECE) and a well-defined dependency direction
(depend only on lower layers). Each layer is open for extension
(OCP): adding a rule, declaration, or reporter is purely additive.

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 4 — Public API                                           │
│    Metanorma::Iso.validate(xml)  → Report                       │
│    `metanorma-iso validate FILE`                                │
│    Reporters: text, json, yaml                                  │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3 — Semantic Rules (this repo + siblings)                │
│    One class per ISO_N / STANDOC_N key                          │
│    Inherits Rules::Base + TreeTraversal mixin                   │
│    Operates ONLY on what Layer 1 successfully parsed            │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2 — Collection Validators                                │
│    validates_uniqueness_of, validates_min_count                 │
│    Lutaml::Model::Collection subclasses                         │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1 — Document Model (metanorma-document)                  │
│    Typed Serializables + declarative validations                │
│    (required:, values:, pattern:, collection: N..M)             │
│    Owns STRUCTURAL validity via from_xml + validate             │
└─────────────────────────────────────────────────────────────────┘
```

## Why layered

A contributor asked in procedural terms: *"why isn't TODO X validated
here?"* The layered answer: each kind of validation has its proper
home. Putting structural checks in semantic rules duplicates work the
model already does and couples two independent concerns.

| Concern                          | Layer | Owner                    |
|-----------------------------------|-------|--------------------------|
| Element X must be a child of Y    | 1     | metanorma-document model |
| Attribute X must match regex      | 1     | metanorma-document model |
| Attribute X is required           | 1     | metanorma-document model |
| IDs must be unique                | 2     | metanorma-document model |
| Sequence ordering (term > notes)  | 1     | metanorma-document model (validate_sequence!) |
| ISO 5: doctype must be valid ISO  | 3     | metanorma-iso (DoctypeRule) |
| ISO 21: every annex is referenced | 3     | metanorma-iso (UnreferencedAssetsRule) |
| ISO 23: foreword has subclauses   | 3     | metanorma-iso (ForewordStructureRule) |
| Style: numbers, units, ambiguous  | 3     | metanorma-iso (Style*Rule) |

A rule belongs to Layer 3 when it expresses a *semantic* constraint
(about meaning, content, or convention). It belongs to Layer 1 when it
expresses a *structural* constraint (about shape, presence, type).

## What this means in practice

A contributor adding a new validation rule asks: **"Is this structural
or semantic?"**

- **Structural** → add a Layer 1 declaration to the metanorma-document
  model class. Open a PR to metanorma-document. Example: making
  `IsoPreface#foreword` `required: true`.
- **Semantic** → add a Layer 3 rule class in this repo. Add one
  autoload line. Example: `DoctypeRule`.

This separation makes the rule registry self-documenting: every file
under `lib/metanorma/iso/validation/rules/` is a semantic rule, full
stop. Structural constraints live with the model that owns them.

## Public API (TODO 35)

The layering enables validation to be invoked independently of
compilation. A user can:

```ruby
report = Metanorma::Iso.validate(xml_string)
report.valid?         # => true / false
report.errors         # => [#<Issue code: "ISO_5", ...>]
report.to_json        # => structured JSON for tooling
puts Metanorma::Iso::Validation::Reporter::Text.new.format(report)
```

```bash
$ metanorma-iso validate document.xml --format json
$ metanorma-iso validate document.xml --format text
```

This is impossible in the legacy pipeline because validation is
welded to the converter. The layered design makes it a natural
consequence — `Metanorma::Iso::Validation::ModelValidator.run` is
already public; TODO 35 wraps it with a stable external contract and
a CLI shim.

## Cross-repo work that completes the architecture

The migration is complete in metanorma-iso. Two adjacent repos have
follow-up work that, when landed, removes every legacy code path:

### metanorma-document (TODO 33)

Each item below is a small, focused PR. None blocks the others.

- `IsoPreface#foreword` → `required: true` (enables Layer 1 gating)
- `IsoDocumentType` → `values: [...]` enum
- `IsoDocumentSubtype` → `values: [...]` enum
- `IsoAdmonitionBlock` → typed enum on `:type`
- `SubElement` → preserve nested `<sub>` children (subscript depth)
- `FigureBlock#figure` → retype as `FigureBlock` (recursive) instead of
  `Subfigure`; or extend `Subfigure` to carry image/fn/note children
- `BibliographicDate#on` → retype as `:string` (or sentinel-aware) to
  preserve en-dash for undated references
- `StandardReferencesSection` → add `:clauses` and `:subsections`
  collections so nested clause/refs survive from_xml

### metanorma-standoc (TODO 34)

The STANDOC_* rules migrate to Layer 3 classes following the same
pattern (one file per code, autoload registry). The `repeat_id_validate`
population logic moves to a `StandocIndexRule` that fills SharedState.
After migration, the override hacks in `Iso::Validate` (currently
no-op'ing standoc's duplicate detection) go away.

## Why this is better than the procedural original

| Procedural (legacy)                    | Layered (this branch)                |
|----------------------------------------|--------------------------------------|
| One 270-line `Validate` class          | ~32 single-responsibility rule classes |
| XPath strings hardcoded in Ruby        | Model-driven navigation              |
| RNG + Jing separate                    | Layer 1 owns structure               |
| Validation welded to compile           | Public API + CLI                     |
| Adding a rule = editing switch case    | Adding a rule = new file + autoload  |
| Output only via .err.html              | Report serializes to JSON/YAML/text  |
| Specs require end-to-end compile       | Rule specs run on isolated fixtures  |

The architectural win is *locality of change*: a new rule touches one
file; a new output format touches one reporter; a new model attribute
touches one declaration. Maintenance cost is proportional to the
change, not to the size of the codebase.
