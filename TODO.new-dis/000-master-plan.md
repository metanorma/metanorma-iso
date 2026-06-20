# 000 — Master Plan: Fully Adopt DIS Era C Template

## Goal

Generate DOCX output that uses **only** the canonical DIS Era C template
(`spec/fixtures/20250530-ISO_DIS_15926-100.docx`) as source of truth for:

1. Style definitions (`styles.yml`)
2. Numbering definitions (`numbering.yml`)
3. Document defaults (`doc_defaults.yml`)
4. Style mapping (`style_mapping.yml`)

…with the adapter (Ruby code) **never** holding style IDs, numbering IDs,
or fallback chains as literals. All visual concerns are configured; the
code is purely orchestration.

## Why now

The audit in `BUGS.gen/021-iso-template-style-audit.md` established:

- Our `data/iso-dis/styles.yml` and `numbering.yml` were extracted from
  `ISO 6709 ed.3` (Era B). The spec fixture is `DIS 15926-100` (Era C).
- `style_mapping.yml` references Era C style IDs (`Warningtext`,
  `Warningtitle`, `InlineCode`, `zzCoverlarge`, `zzCopyrightaddress`,
  `TermsAdmitted`) that do NOT exist in our own extracted `styles.yml`.
- The adapter still has fallback chains and at least one hardcoded
  style string (`"ANNEX"` at adapter.rb:942, `"TOC#{level}"` literal
  fallback at toc_builder.rb:249).
- 14 Era C content styles defined in the DIS 15926 reference are not
  yet mapped (`KeyText`, `KeyTitle`, `Box-begin`/`Box-end`/`Box-title`,
  `Figuredescription`, `Figurenote`, `Figuresubtitle`, `Dimension50/75/100`,
  `Disp-quotep`, `Notice`, `InlineCodeBold`, `BlockText`).
- Adapter is 1233 lines, doing many concerns. MECE/DRY/OCP violations.

## Architecture target

```
┌─────────────────────────────────────────────────────────────────┐
│ data/iso-dis/*.yml  ← extracted from DIS 15926 (Era C)          │
│   styles.yml  numbering.yml  doc_defaults.yml  style_mapping.yml│
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│ DocxStyleMapping (pure YAML loader, no logic)                   │
│ StyleResolver (lookup + context dispatch; strict — raises)      │
│ StyleMappingValidator (verifies mapping ⊆ styles.yml)           │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│ Adapter (orchestrator — no style literals, no fallback chains)  │
│ delegates to per-content-type Renderers:                        │
│   CoverRenderer, BoilerplateRenderer, TocBuilder,               │
│   FormulaRenderer, SourcecodeRenderer, CommentRenderer,         │
│   NoteRenderer, ExampleRenderer, AdmonitionRenderer,            │
│   FigureRenderer, TableRenderer, TermRenderer,                  │
│   BibliographyRenderer, DefinitionListRenderer, QuoteRenderer,  │
│   ListRenderer, ClauseRenderer, HeaderFooterRenderer            │
└─────────────────────────────────────────────────────────────────┘
```

## MECE phases

### Phase 1 — Data alignment (foundation)
- [001](001-reextract-yaml-from-dis-15926.md) Re-extract `styles.yml`,
  `numbering.yml`, `doc_defaults.yml` from `20250530-ISO_DIS_15926-100.docx`
- [002](002-audit-and-correct-style-mapping.md) Audit and correct
  `style_mapping.yml` against new YAML data
- [003](003-add-style-exclusion-list.md) Add `excluded_styles` block to
  prevent 8601-era pollution from re-entering
- [004](004-document-template-era-in-yaml.md) Document template era
  explicitly in YAML header

### Phase 2 — Architecture (purity)
- [005](005-style-mapping-validator.md) New `StyleMappingValidator` class
- [006](006-style-resolver-strict-mode.md) `StyleResolver` raises on
  unknown style instead of returning nil
- [007](007-eliminate-fallback-chains.md) Remove all `||` style fallback
  chains from adapter, StyleResolver, TocBuilder
- [008](008-eliminate-hardcoded-style-strings.md) Remove all string
  literals for style IDs (`"ANNEX"`, `"TOC#{level}"`, etc.)
- [009](009-class-based-visitor-dispatch.md) Replace string-class-name
  dispatch with polymorphic method dispatch on model classes
- [010](010-extract-content-block-renderers.md) Extract per-content-type
  renderers from the 1233-line adapter (MECE decomposition)

### Phase 3 — Features (Era C mappings)
- [011](011-formula-key-list-rendering.md) Render formula `<dl>` as
  KeyTitle + KeyText paragraphs (closes BUG 049)
- [012](012-box-style-for-admonitions.md) Use `Box-begin`/`Box-end`/
  `Box-title` for notes, examples, warnings
- [013](013-figure-extras-rendering.md) Render `Figuredescription`,
  `Figurenote`, `Figuresubtitle`
- [014](014-dimension-style-for-images.md) Apply `Dimension50/75/100`
  for image sizing
- [015](015-disp-quote-rendering.md) Use `Disp-quotep` for block quotes
- [016](016-inline-code-character-styles.md) Use `InlineCode` and
  `InlineCodeBold` character styles
- [017](017-header-footer-style-wiring.md) Wire `HeaderCentered`,
  `FooterCentered`, `FooterPageNumber`, `FooterPageRomanNumber`
- [018](018-numbering-yml-realignment.md) Realign `numbering.yml` to
  canonical 7-abstractNum Era C scheme

### Phase 4 — Specs (full coverage)
- [019](019-spec-style-mapping-integrity.md) Style mapping integrity
  spec: every mapped styleId exists in styles.yml
- [020](020-spec-adapter-no-hardcoded-styles.md) Adapter purity spec:
  no style string literals in adapter code
- [021](021-spec-style-resolver-strict-mode.md) StyleResolver spec:
  raises on unknown key, returns single canonical style
- [022](022-spec-per-renderer-output.md) Per-renderer output specs with
  Era C assertions
- [023](023-spec-end-to-end-rice-output.md) End-to-end rice DOCX spec:
  output matches DIS 15926 reference structure

## Architectural rules enforced by this plan

1. **All styleIds flow from `style_mapping.yml`** — no string literals
   in Ruby code.
2. **No fallback chains** (`a || b || c`) — YAML has exactly one
   mapping per semantic concept.
3. **StyleResolver is strict** — `paragraph_style(:unknown)` raises
   `IsoDoc::Iso::Docx::UnknownStyleError`.
4. **StyleMappingValidator runs in CI** — fails build if mapping
   references a styleId missing from `styles.yml`.
5. **Adapter is thin orchestrator** — content rendering is delegated
   to per-type Renderer classes (OCP: new content type = new renderer
   class + YAML entry, no edits to Adapter).
6. **Context is enum, not booleans** — replaces `@context.in_note ||
   @context.in_example || ...` with `@context.zone == :note`.
7. **No `send`, `instance_variable_set/get`, `respond_to?`** — type
   checks use `is_a?`, attribute access uses public methods or
   `class.attributes.key?(:name)` pattern.
8. **No `require_relative`** — every loadable class is registered via
   `autoload` in its immediate parent namespace's file.
9. **Real model instances in specs** — no `double()`.
10. **Single source of truth** — `data/iso-dis/` files are the only
    source; never copy style IDs into Ruby constants.

## Success criteria

- `bundle exec rspec spec/isodoc/docx/style_mapping_integrity_spec.rb`
  passes (no mapped styleId is missing from styles.yml).
- `bundle exec rspec spec/isodoc/docx/adapter_purity_spec.rb` passes
  (no hardcoded style strings in adapter).
- `bundle exec rspec spec/isodoc/docx/` runs green on Era C assertions
  (Warningtext, Box-*, KeyText, etc. present in output).
- `canon diff` between rice DOCX output and DIS 15926 reference shows
  no missing style references.
- Adapter is < 600 lines (currently 1233) after content renderer
  extraction.
