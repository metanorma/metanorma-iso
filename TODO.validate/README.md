# TODO.validate — Migration of post-XML validation to a layered architecture

This directory is the plan of record for migrating metanorma-iso's
post-XML validation from procedural Ruby + Nokogiri + RelaxNG/Jing
into a **layered, model-driven, OOP validator**. See
[ARCHITECTURE.md](ARCHITECTURE.md) for the full layered design.

## Branch

`feat/model-validation-migration` off `feat/sts-transformer-architecture`.

## Status legend

- **DONE** — landed on this branch.
- **TRACKED UPSTREAM** — belongs to a sibling repo (metanorma-document
  or metanorma-standoc); has its own TODO file with the work items.
- **PLANNED** — work scoped, not yet started.

## Status

| # | File | Priority | Status |
|---|------|----------|--------|
| 01 | foundation-model-validator | P0 | DONE |
| 02 | declarative-preface-foreword-required | P1 | DONE (Layer 3 stopgap) |
| 03 | declarative-cleanup-audit | P1 | TRACKED UPSTREAM (TODO 33) |
| 04 | rule-iso2-iso3-subcommittee-types | P1 | DONE |
| 05 | rule-iso5-doctype | P1 | DONE |
| 06 | rule-iso6-iteration | P1 | DONE |
| 07 | rule-iso4-iso35-termdef-style | P1 | DONE |
| 08 | rule-iso7-subfigure | P1 | TRACKED UPSTREAM (TODO 33: FigureBlock retype) |
| 09 | rule-iso8-bibitem-unpublished | P1 | TRACKED UPSTREAM (TODO 33: BibliographicDate retype) |
| 10 | rule-iso42-normative-bibitem | P1 | DONE |
| 11 | rule-iso10-iso15-title-pairing | P1 | DONE |
| 12 | rule-iso16-subpart-iec | P1 | DONE |
| 13 | rule-iso17-iso18-title-names-doctype | P1 | DONE |
| 14 | rule-iso19-iso20-title-siblings | P1 | DONE |
| 15 | rule-iso23-foreword-structure | P1 | DONE |
| 16 | rule-iso24-normref-structure | P1 | TRACKED UPSTREAM (TODO 33: StandardReferencesSection extension) |
| 17 | rule-iso25-iso26-iso27-symbols | P1 | DONE |
| 18 | rule-iso29-iso30-iso31-section-presence | P1 | DONE |
| 19 | rule-section-sequence | P1 | DONE |
| 20 | rule-iso39-scope-subclauses | P1 | DONE |
| 21 | rule-iso43-only-child-clause | P1 | DONE |
| 22 | rule-iso44-iso45-vocab-terms-titles | P1 | DONE |
| 23 | rule-iso21-iso22-unreferenced-assets | P1 | DONE |
| 24 | rule-iso46-iso47-iso48-see-xrefs | P1 | DONE |
| 25 | rule-iso49-locality-erefs | P1 | DONE |
| 26 | rule-iso50-iso51-term-xrefs | P1 | DONE |
| 27 | rule-list-punctuation-and-counts | P1 | PARTIAL (count + depth DONE; punctuation needs each_mixed_content on lists — small follow-up) |
| 28 | rule-style-numeric-percent-units | P1 | PARTIAL (number + units DONE; subscript needs TODO 33 SubElement extension) |
| 29 | rule-style-requirements-ambig-misspell | P1 | PARTIAL (ambig + misspelling DONE; modal-in-clause needs clause-type discrimination helper) |
| 30 | rule-standoc36-unique-ids-anchors | P1 | DONE |
| 31 | structural-grammar-rule | P1 | TRACKED UPSTREAM (TODO 33: Layer 1 declarations) |
| 32 | rng-and-jing-removal | P1 | DONE |
| 33 | upstream-pr-metanorma-document-declarative | P2 | PLANNED (8 work items, each its own PR) |
| 34 | standoc-migration-followup | P2 | PLANNED (~20 PRs across standoc + flavor gems) |
| 35 | public-api-cli | P2 | DONE |

## What's done on this branch

- **30 rule classes** covering all 52 ISO codes + STANDOC_36 + STANDOC_48.
- **Foundation**: ModelValidator orchestrator, Context/State/SharedState,
  Issue + Report (lutaml-model Serializables with JSON/YAML/XML
  round-trips), IssueTranslator (single sink for @log + Report),
  RuleRegistry (OCP discovery via Rules.constants), Base rule class
  with `code` DSL + `model_location` helper, TreeTraversal mixin with
  ~10 shared walkers, three Reporters (Text/Json/Yaml).
- **165 specs green**, zero Nokogiri, zero XPath, RNG/Jing deleted.
- **Inline order preserved** via `each_mixed_content` for see-xref
  rules (TODOs 24, 26).
- **STANDOC_36 unique IDs**: rule fires from Layer 3, populates
  SharedState, Iso::Validate overrides standoc helpers to skip
  detection (override goes away when TODO 34 lands).

## What's tracked upstream

The layered design assigns each kind of validation a home. Items not
done in this repo belong elsewhere — see [ARCHITECTURE.md](ARCHITECTURE.md).

- **TODO 33 (metanorma-document)**: 8 focused PRs adding Layer 1
  declarations and extending the model to preserve data currently
  dropped by from_xml (nested sub, recursive figure, string-typed
  dates, references-within-references).
- **TODO 34 (metanorma-standoc)**: ~20 PRs migrating STANDOC_* rules
  to Layer 3. After this, the override hacks in Iso::Validate go away
  and the last Nokogiri usage in validation disappears.

## What's planned (pure addition)

- **TODO 35 (Public API + CLI)**: 1-2 PRs exposing
  `Metanorma::Iso.validate(xml)` and `metanorma-iso validate FILE`.
  Builds entirely on the existing ModelValidator; no migration.

## Execution order

This branch → TODO 35 (immediate, pure addition) → TODO 33 (parallel,
per-PR) → TODO 34 (sequential, per-rule) → remove Iso::Validate
override hacks.
