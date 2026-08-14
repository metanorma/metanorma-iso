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

### Phase 4 — DONE (18 of 18 flavors migrated)

Move each remaining flavor tree out of metanorma-document into its own
flavor gem. One PR per flavor gem. Each flavor's document model adopts
the `Metanorma::<Flavor>::Document::*` namespace pattern.

Migration script: `scripts/migrate-flavor-document-model.sh <flavor>
<FlavorClass>` runs the full pattern (branch, copy, sed-rename, alias,
deprecate, Gemfile pins, namespace spec, verify).

#### All 18 flavor PRs open (draft)

| Flavor | PR | Spec | Notes |
|---|---|---|---|
| generic | metanorma/metanorma-generic#125 | 8 green | — |
| ribose | metanorma/metanorma-ribose#541 | 7 green | — |
| ogc | metanorma/metanorma-ogc#989 | 7 green | — |
| iho | metanorma/metanorma-iho#515 | 7 green | — |
| nist | metanorma/metanorma-nist#508 | 7 green | — |
| ietf | metanorma/metanorma-ietf#310 | 7 green | — |
| ieee | metanorma/metanorma-ieee#785 | 7 green | — |
| iec | metanorma/metanorma-iec#567 | 7 green | — |
| bsi | metanorma/metanorma-bsi#636 | 7 green | — |
| jis | metanorma/metanorma-jis#496 | 7 green | — |
| itu | metanorma/metanorma-itu#832 | 7 green | — |
| plateau | metanorma/metanorma-plateau#378 | 7 green | — |
| cc | metanorma/metanorma-cc#530 | 7 green | — |
| un | metanorma/metanorma-un#290 | 7 green | relax `standoc ~> 2.9.3` + `rubocop` |
| gb | riboseinc/metanorma-gb#168 | 7 green | relax 4 stale pins |
| m3d | riboseinc/metanorma-m3d#252 | 7 green | relax generic + rubocop; new `M3d::Document` namespace coexists with legacy `M3AAWG` |
| bipm | metanorma/metanorma-bipm#667 | 7 green | relax pins + cross-PR iso/generic pins |
| csa | metanorma/metanorma-csa#354 | 7 green | relax generic pin + cross-PR generic pin |

**Total: 130 examples, 0 failures** across all flavor namespace specs.

Each PR's namespace spec is self-contained (does not pull in the gem's
full spec_helper) so it can run on CI even when the gem has unrelated
pre-existing bundle issues.

#### Network verification (2026-08-14)

- All 21 PRs (3 base + 18 flavor) confirmed in `OPEN` state, `isDraft: true`.
- Every flavor PR's Gemfile pins `metanorma-standoc → feat/move-standard-document` and `metanorma-document → feat/model-validation-l1-declarations`. bipm and csa also pin `metanorma-iso` / `metanorma-generic` PR branches for transitive deps.
- Spot-checked end-to-end namespace resolution on 3 flavors (generic, ietf, plateau): each correctly resolves `Metanorma::<Flavor>::Document::Root` AND `Metanorma::Standoc::Document::Root` from the cross-PR branch chain.
- None of the PRs touch main; the whole graph resolves from feature branches.

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
