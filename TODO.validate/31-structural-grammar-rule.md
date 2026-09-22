# 31 — Rule: Structural grammar (parent-child allow-lists)

## Why
This is the hidden P0 piece of the migration. RNG encodes parent-child
allow-lists (e.g. "a `<term>` may contain `<preferred>`, `<admitted>`,
`<deprecates>`, `<termsource>` but NOT `<clause>`"). These constraints are
NOT visible in any ISO_N or STANDOC_N key — RNG violations surface as
generic STANDOC_7 "Metanorma XML Syntax" errors.

`IsoDocument::Root.from_xml` silently drops unknown children, so without
this rule, removing RNG would regress structural validation entirely.

## Files
- All RNG files under `lib/metanorma/iso/*.rng` (to extract allow-lists).
- `lib/metanorma/iso/validation/rules/structural_grammar_rule.rb` — new.

## Plan
1. Build a parent-child allow-list table from the RNG definitions. Encode as
   a Ruby constant: `ALLOWED_CHILDREN = { "Term" => %w[TermAttributes
   preferred admitted deprecates termdomain termdefinition termnote
   termexample termsource term], ... }.freeze`.
2. Create `StructuralGrammarRule < Base` that walks every model node, reads
   its `element_order` (lutaml-model tracks this), and verifies each child
   name is in the parent's allow-list.
3. Spec covers a known-good document (skip) and a synthetic document with
   one disallowed child at each level (flag).
4. Code `STANDOC_7` for findings.

## Alternative (preferred after investigation)
If `lutaml-model`'s `validate_sequence!` (already in `Validation` module)
covers element ordering AND presence-by-mapping, structural rules may be
implicitly enforced. Validate this empirically by feeding a malformed
document to `from_xml` + `validate` and observing what fires.

If `validate_sequence!` covers it, this TODO becomes a thin "verify and
delete" rather than a new rule. If not, this TODO builds the explicit
allow-list rule.

## Risk
Without this TODO, TODO 32 cannot land — removing RNG would silently regress.

## Acceptance
- Spec green.
- Empirical verification: feed malformed XML, confirm structural findings.
- Rice document error log unchanged.
