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

### Phase 4 — IN PROGRESS (13 of ~18 flavors migrated)

Move each remaining flavor tree out of metanorma-document into its own
flavor gem. One PR per flavor gem. Each flavor's document model adopts
the `Metanorma::<Flavor>::Document::*` namespace pattern.

Migration script: `scripts/migrate-flavor-document-model.sh <flavor>
<FlavorClass>` runs the full pattern (branch, copy, sed-rename, alias,
deprecate, Gemfile pins, namespace spec, verify).

#### Successfully migrated (draft PRs open)

| Flavor | PR | Spec |
|---|---|---|
| generic | metanorma/metanorma-generic#125 | 8 examples green |
| ribose | metanorma/metanorma-ribose#541 | 7 examples green |
| ogc | metanorma/metanorma-ogc#989 | 7 examples green |
| iho | metanorma/metanorma-iho#515 | 7 examples green |
| nist | metanorma/metanorma-nist#508 | 7 examples green |
| ietf | metanorma/metanorma-ietf#310 | 7 examples green |
| ieee | metanorma/metanorma-ieee#785 | 7 examples green |
| iec | metanorma/metanorma-iec#567 | 7 examples green |
| bsi | metanorma/metanorma-bsi#636 | 7 examples green |
| jis | metanorma/metanorma-jis#496 | 7 examples green |
| itu | metanorma/metanorma-itu#832 | 7 examples green |
| plateau | metanorma/metanorma-plateau#378 | 7 examples green |
| cc | metanorma/metanorma-cc#530 | 7 examples green |

Each PR's namespace spec is self-contained (does not pull in the gem's
full spec_helper) so it can run on CI even when the gem has unrelated
pre-existing bundle issues (e.g. pubid-* 1.x→2.x migration).

#### Blocked (need per-gem work outside this migration's scope)

| Flavor | Blocker | Suggested fix |
|---|---|---|
| bipm | gemspec depends on `metanorma-iso ~> 3.4.2` (released) — pulls old standoc chain | Add metanorma-iso PR-branch pin to Gemfile |
| m3d | gemspec `rubocop ~> 1.5.2` conflicts with isodoc | Relax rubocop constraint in m3d gemspec |
| gb | gemspec `twitter_cldr ~> 4.4.4` and `rubocop = 0.54.0` conflict with isodoc | Update constraints in gb gemspec |
| un | gemspec `metanorma-standoc ~> 2.9.3` (stale pin) | Update standoc dep in un gemspec |

These blockers are not about my migration — they are pre-existing
per-gem dependency hygiene issues. Each flavor's maintainer should fix
the constraint, then re-run `scripts/migrate-flavor-document-model.sh`.

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
