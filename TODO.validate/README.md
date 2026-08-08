# TODO.validate — Migration of post-XML validation to lutaml-model

This directory contains the plan of record for migrating metanorma-iso's
post-XML-generation validation from Ruby XPath + RelaxNG/Jing to
lutaml-model native validation (Layer 1 declarations + Layer 2 collection
validators + Layer 3 Rule classes) operating on
`Metanorma::IsoDocument::Root`.

## Context
- Plan file: `~/.claude/plans/typed-prancing-pond.md` (full architecture)
- Branch: `feat/model-validation-migration` (off
  `feat/sts-transformer-architecture`)
- Each file is one PR-sized unit of work.
- Cutover is rule-by-rule with no dual-run; old Ruby + RNG counterparts are
  deleted in the same commit as the new rule lands.
- Zero Nokogiri in post-XML validation. The single bridge is `doc.to_xml`
  at the validator boundary.

## Status

| # | File | Priority | Status |
|---|------|----------|--------|
| 01 | foundation-model-validator | P0 | DONE |
| 02 | declarative-preface-foreword-required | P1 | TODO |
| 03 | declarative-cleanup-audit | P1 | TODO |
| 04 | rule-iso2-iso3-subcommittee-types | P1 | DONE |
| 05 | rule-iso5-doctype | P1 | DONE |
| 06 | rule-iso6-iteration | P1 | DONE |
| 07 | rule-iso4-iso35-termdef-style | P1 | DONE |
| 08 | rule-iso7-subfigure | P1 | TODO |
| 09 | rule-iso8-bibitem-unpublished | P1 | TODO |
| 10 | rule-iso42-normative-bibitem | P1 | TODO |
| 11 | rule-iso10-iso15-title-pairing | P1 | DONE |
| 12 | rule-iso16-subpart-iec | P1 | DONE |
| 13 | rule-iso17-iso18-title-names-doctype | P1 | DONE |
| 14 | rule-iso19-iso20-title-siblings | P1 | DONE |
| 15 | rule-iso23-foreword-structure | P1 | DONE |
| 16 | rule-iso24-normref-structure | P1 | BLOCKED on TODO 33 (see below) |
| 17 | rule-iso25-iso26-iso27-symbols | P1 | DONE |
| 18 | rule-iso29-iso30-iso31-section-presence | P1 | DONE |
| 19 | rule-section-sequence | P1 | DONE |
| 20 | rule-iso39-scope-subclauses | P1 | DONE |
| 21 | rule-iso43-only-child-clause | P1 | DONE |
| 22 | rule-iso44-iso45-vocab-terms-titles | P1 | DONE |
| 23 | rule-iso21-iso22-unreferenced-assets | P1 | TODO |
| 24 | rule-iso46-iso47-iso48-see-xrefs | P1 | TODO |
| 25 | rule-iso49-locality-erefs | P1 | TODO |
| 26 | rule-iso50-iso51-term-xrefs | P1 | TODO |
| 27 | rule-list-punctuation-and-counts | P1 | TODO |
| 28 | rule-style-numeric-percent-units | P1 | TODO |
| 29 | rule-style-requirements-ambig-misspell | P1 | TODO |
| 30 | rule-standoc36-unique-ids-anchors | P1 | DONE |
| 31 | structural-grammar-rule | P1 | TODO |
| 32 | rng-and-jing-removal | P1 | TODO |
| 33 | upstream-pr-metanorma-document-declarative | P2 | TODO |
| 34 | standoc-migration-followup | P2 | TODO |

## Execution order
Phase A (foundation) → Phase B (Layer 1) → Phase C (simple rules) →
Phase D (complex rules) → Phase E (structural grammar) →
Phase F (RNG removal) → Phase G (upstream/standoc).

TODO 30 (Layer 2 IDs) MUST land before TODOs 23-26 (xref rules) because they
consume `SharedState` populated by 30.
TODO 31 (structural grammar) MUST land before TODO 32 (RNG removal).
