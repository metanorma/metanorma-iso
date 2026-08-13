# 36 — Model ownership migration: StandardDocument → metanorma-standoc, IsoDocument ← metanorma-iso

## Why

The document model is currently mis-homed. metanorma-document ships
`Document::Components`, `BasicDocument`, `StandardDocument`, AND
`IsoDocument` (plus other flavor models: ItuDocument, IeeeDocument,
BsiDocument, CsaDocument, IecDocument). The layered ownership should be:

```
metanorma-document  → Metanorma::Document::Components, Metanorma::BasicDocument
metanorma-standoc   → Metanorma::Standoc::Document         (this TODO)
metanorma-iso       → Metanorma::Iso::Document (canonical)   (already done)
metanorma-itu       → Metanorma::Itu::Document               (follow-up)
metanorma-ieee      → Metanorma::Ieee::Document              (follow-up)
metanorma-bsi       → Metanorma::Bsi::Document               (follow-up)
metanorma-csa       → Metanorma::Csa::Document               (follow-up)
metanorma-iec       → Metanorma::Iec::Document               (follow-up)
```

This TODO tracks the **StandardDocument move + namespace rename** in a
3-gem scope (metanorma-standoc, metanorma-iso, metanorma-document).

## Status (2026-08-13)

### Phase 1 — DONE (PR metanorma/metanorma-standoc#1232)

StandardDocument moved from metanorma-document to metanorma-standoc,
renamed to `Metanorma::Standoc::Document`. 151 files at
`lib/metanorma/standoc/document*`. Backwards-compat alias
`Metanorma::StandardDocument = Metanorma::Standoc::Document` marked
deprecated via `deprecate_constant`.

### Phase 2 — DONE (PR metanorma/metanorma-iso#1618)

metanorma-iso requires `metanorma/standoc` so the parent class resolves
from standoc. `Metanorma::Iso::Document` is the canonical name
(`lib/metanorma/iso/document*`, 60 files). All internal call sites
updated to use the new namespaces — no internal `Metanorma::StandardDocument`
or `Metanorma::IsoDocument` references remain.

Backwards-compat alias `Metanorma::IsoDocument = Metanorma::Iso::Document`
marked deprecated via `deprecate_constant`.

### Phase 3 — DEFERRED (out of 3-gem scope)

Removal of `lib/metanorma/standard_document*` and
`lib/metanorma/iso_document*` from metanorma-document. Blocked: other
flavor trees in metanorma-document (ItuDocument, IeeeDocument,
IetfDocument, BsiDocument, CsaDocument, IecDocument) extend
`StandardDocument::Root` as their parent class. Removing the parent
breaks the children.

PR metanorma/metanorma-document#45 marks both autoloads as deprecated
in `lib/metanorma/document.rb` but does not remove the trees.

### Phase 4 — DEFERRED (out of 3-gem scope)

Move each remaining flavor tree out of metanorma-document into its own
flavor gem (itu, ieee, bsi, csa, iec, ietf, jis, oiml). One PR per
flavor gem. Each flavor's document model adopts the
`Metanorma::<Flavor>::Document::*` namespace pattern.

### Phase 5 — DEFERRED (out of 3-gem scope)

metanorma-document shrinks to Document components only. Final rename
to `metanorma-document-model` is optional.

## Bug fixes in this 3-gem scope (Phase A)

- **A1 (load-order trap)**: `module Foo::Bar` chained declarations
  silently broke if the file was required before its parent's file.
  Fixed by forward-declaring the parent namespace at the top of each
  affected file. Verified in standoc/document.rb and iso/document.rb.
- **A2 (alias re-init warning)**: when an older metanorma-document
  release was bundled alongside the renamed gems, Ruby warned
  "already initialized constant" on the alias assignment. Fixed via
  `remove_const` before reassignment.
- **A3 (Root superclass)**: audited Iso::Document::Root — extends
  Serializable directly, matching the released 0.4 behavior. Design
  choice, not a bug. No change.

## Internal namespace cleanup (Phase B)

- **B1**: replaced 30+ `Metanorma::StandardDocument::*` references
  inside the Iso::Document tree with `Metanorma::Standoc::Document::*`.
- **B2**: replaced all `Metanorma::IsoDocument::*` references in
  lib/metanorma/iso/ and lib/isodoc/iso/ with `Metanorma::Iso::Document::*`.
  Updated require paths from `metanorma/iso_document` to
  `metanorma/iso/document` in lib + spec helpers.
- **B3**: aliases are now public-API-only. No internal call site uses
  them.

## Deprecation signals (Phase C)

- **C1**: `Metanorma::StandardDocument` and `Metanorma::IsoDocument`
  declared via `deprecate_constant`. Consumers referencing the old
  names see `warning: constant X is deprecated` under `ruby -W`.
- **C2**: metanorma-document's `document.rb` autoloads for
  StandardDocument + IsoDocument carry explicit deprecation comments
  linking to the tracking PRs.

## What silences the maintainer critique

- "Buggy" — Phase A: load-order, alias warning, Root superclass audit
  all addressed.
- "Incomplete rename" — Phase B: internal refs use new namespace
  consistently. Aliases visibly external-only.
- "No deprecation story" — Phase C: callers see a warning, alias is
  documented as scheduled-for-removal.

## What this does NOT silence

- "Rename is half-finished across the ecosystem" — true. ItuDocument,
  IeeeDocument, IetfDocument, BsiDocument, CsaDocument, IecDocument
  still live in metanorma-document (Phase 4). The aliases stay until
  each flavor migrates.
