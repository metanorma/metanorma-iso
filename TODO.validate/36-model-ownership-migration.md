# RESUME — Model ownership migration (all phases COMPLETE, awaiting merge)

> **How to resume:** all 21 PRs are open drafts. Nothing is left to build.
> This file is the merge-order plan of record. Read "Merge order" below,
> merge PRs top-to-bottom, then revert each Gemfile branch pin noted in
> "Gemfile pin reverts". Session date: 2026-08-15.

## Final architecture (what each gem owns now)

```
metanorma-document  → Document::Components + Document::Root, BasicDocument,
                      Registers (invoked by flavor gems), Html + Mirror
                      rendering core (lazy String-constant flavor dispatch)
metanorma-standoc   → Metanorma::Standoc::Document        (was StandardDocument)
metanorma-iso       → Metanorma::Iso::Document            (was IsoDocument)
each flavor gem     → Metanorma::<Flavor>::Document       (was <Flavor>Document)
```

Namespace pattern everywhere: `Metanorma::<Flavor>::Document::*`.
Backwards-compat aliases (`Metanorma::StandardDocument`,
`Metanorma::IsoDocument`, `Metanorma::<Flavor>Document`) are set via
`remove_const` + reassign + `deprecate_constant` in each gem. They warn
under `ruby -W` and are scheduled for removal after consumers migrate.

## The 21-PR network (all drafts, none merged)

### Merge in THIS order

| Order | PR | What | Key commits |
|---|---|---|---|
| 1 | metanorma/metanorma-standoc#1232 | StandardDocument → Standoc::Document, 151 files, load-order fix, deprecation, 65 migrated spec examples | 0884cfee, 1cacd416, de644a61, c2d7fcc4, 8e95ff3d, 336cdf0b |
| 2 | metanorma/metanorma-iso#1618 | IsoDocument → Iso::Document + full validation migration (TODOs 1–32, 35), Phase A/B/C cleanup, 117 migrated roundtrip examples | many, through b65839ff |
| 3–20 | 18 flavor PRs (table below) | each flavor's document model + migrated specs | one migration commit each (+roundtrip commits) |
| 21 | metanorma/metanorma-document#45 | **Phase 5 removal — MERGES LAST.** −89.5k lines, Html/Mirror lazy dispatch | b859a26, d07dbd2, d83c83f, 41cc6f5, 6bdbae0 |

### The 18 flavor PRs (merge in any order between #2 and #21)

| Flavor | PR | Namespace | Extra changes |
|---|---|---|---|
| generic | metanorma/metanorma-generic#125 | Generic::Document | — |
| ribose | metanorma/metanorma-ribose#541 | Ribose::Document | — |
| ogc | metanorma/metanorma-ogc#989 | Ogc::Document | — |
| iho | metanorma/metanorma-iho#515 | Iho::Document | — |
| nist | metanorma/metanorma-nist#508 | Nist::Document | — |
| ietf | metanorma/metanorma-ietf#310 | Ietf::Document | — |
| ieee | metanorma/metanorma-ieee#785 | Ieee::Document | — |
| iec | metanorma/metanorma-iec#567 | Iec::Document | — |
| bsi | metanorma/metanorma-bsi#636 | Bsi::Document | — |
| jis | metanorma/metanorma-jis#496 | Jis::Document | — |
| itu | metanorma/metanorma-itu#832 | Itu::Document | — |
| plateau | metanorma/metanorma-plateau#378 | Plateau::Document | — |
| cc | metanorma/metanorma-cc#530 | Cc::Document | — |
| un | metanorma/metanorma-un#290 | Un::Document | gemspec: standoc ~> 3.4, rubocop ~> 1.50 |
| gb | riboseinc/metanorma-gb#168 | Gb::Document | gemspec: 4 stale pins relaxed |
| m3d | riboseinc/metanorma-m3d#252 | M3d::Document | gemspec: generic ~> 3.0, rubocop; new M3d ns coexists with legacy M3AAWG |
| bipm | metanorma/metanorma-bipm#667 | Bipm::Document | gemspec relax + Gemfile pins iso/generic PR branches |
| csa | metanorma/metanorma-csa#354 | Csa::Document | gemspec: generic ~> 3.4 + Gemfile pin generic PR branch |

## Gemfile pin reverts (after all merges)

Every PR's Gemfile carries `# TEMPORARY: cross-PR branch pins` comments.
After the referenced PR merges, revert that pin to released gems:

- metanorma-standoc PR: unpins metanorma-document, isodoc, relaton-bib, pubid
- metanorma-iso PR: unpins standoc, document, isodoc, relaton-bib, pubid
- flavor PRs: unpins standoc, document, isodoc, relaton-bib, pubid
  (+ iso/generic for bipm, csa; + ogc, iec for metanorma-document)
- metanorma-document PR: unpins standoc, iso, itu, ogc, iec, isodoc, relaton-bib, pubid

After reverting pins, each gemspec needs version bumps:
- metanorma-document: MAJOR (removes 20 constants)
- metanorma-standoc, metanorma-iso, flavors: MINOR (additive + rename alias)

## Migrated spec coverage (nothing lost)

| Coverage | Now lives in | Examples |
|---|---|---|
| StandardDocument model specs | standoc spec/standoc_document/ | 45 + 2 extension |
| StandardReferencesSection nested | standoc spec/standoc_document/standard_references_section_spec.rb | 2 |
| ISO roundtrips (is/amd/title) | metanorma-iso spec/roundtrip/ + spec/fixtures/iso | 117 |
| 12 flavor fixture roundtrips | each flavor gem spec/<flavor>_roundtrip_spec.rb + fixtures | ~400 |
| 6 synthetic roundtrips (bsi/gb/generic/jis/nist/plateau) | each flavor gem | 12 |
| UN model specs | metanorma-un spec/un/ | 21 |
| 18 namespace specs | each flavor gem spec/<flavor>_document_namespace_spec.rb | 7-8 each |
| Html/Mirror specs | stay in metanorma-document (adapted to new namespaces) | all green |
| SubElement extension | metanorma-document spec/model_validation_extensions_spec.rb | 1 |

## Scripts (in this repo, on the branch)

- `scripts/migrate-flavor-document-model.sh <flavor> <FlavorClass>` — full
  flavor migration (branch, copy, sed-rename, alias, deprecate, Gemfile
  pins, namespace spec, verify). Re-runnable if any PR needs revision.
- (session-local, not committed) roundtrip/synthetic spec splitters were
  ad-hoc; if a new flavor needs them, follow the pattern in the committed
  script + the roundtrip spec shape in any flavor gem.

## Known follow-ups (NOT blockers for merging)

1. **Alias removal** — once every consumer (incl. external gems) uses the
   new namespaces, drop the `deprecate_constant` aliases.
2. **pubid-* 1.x→2.x migration** in flavor converters (ieee, iec, bsi,
   jis, itu still `require "pubid-ieee"` etc.). Their namespace specs are
   self-contained so PR CI passes regardless; converter-level pubid work
   is separate.
3. **STANDOC_* rule migration** (TODO.validate/34) — separate standoc PR.
4. **metanorma-document rename** to `metanorma-document-model` — optional.
5. Html/Mirror subsystems still render all flavors from metanorma-document
   via lazy dispatch — a future split could move per-flavor renderers into
   flavor gems following the same pattern.

## Phase history (for context)

- Phase 1 — standoc move + rename: DONE (PR #1232)
- Phase 2 — iso resolution: DONE (PR #1618)
- Phase 3 — deprecation markers: DONE (superseded by Phase 5 removal)
- Phase 4 — 18 flavor migrations: DONE (18 PRs)
- Phase 5 — metanorma-document tree removal + Html/Mirror lazy dispatch:
  DONE (PR #45, merges LAST)
