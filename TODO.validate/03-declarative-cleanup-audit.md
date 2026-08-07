# 03 — Declarative cleanup audit

## Why
Audit every Layer 1 attribute declaration opportunity across the vendored
IsoDocument tree. Document which attributes can take `required:`,
`collection: N..M`, `values:`, `pattern:` WITHOUT vocabulary mismatch (per
Plan finding #5). Mismatches go to Layer 3 instead.

## Plan
1. Walk `lib/metanorma/iso_document/**/*.rb`. For each `attribute :foo,
   SomeType` declaration, check:
   - Does `foo` correspond to a validator-side XML element with matching
     vocabulary? (Cross-reference `lib/metanorma/iso/validate*.rb`.)
   - Does the RNG constrain its cardinality, enum, or pattern?
2. For each match, propose a Layer 1 declaration.
3. For each mismatch, add an entry to `TODO.validate/03a-<attr>-layer3.md`
   (created as a follow-up if needed).
4. Land declarations in batches (one PR per group of 3-5).

## Candidates to investigate
- `IsoAdmonitionType` (6 enum values) — Layer 1 candidate.
- `IsoDocumentSubtype` (4 enum values) — Layer 1 candidate.
- `IsoBibliographicItem#structured_identifier` cardinality — Layer 1 candidate.
- `IsoDocumentType` enum — Layer 3 (vocabulary mismatch per Plan).

## Acceptance
- Audit document at `TODO.validate/03-audit.md` listing every attribute with
  a decision: Layer 1 / Layer 3 / N/A.
- Subsequent Layer 1 TODOs derived from this audit.
