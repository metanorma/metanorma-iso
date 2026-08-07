# 16 — Rule ISO_24: Normative references subclauses

## Why
`validate_section.rb:normref_validate` flags normative references with
subclauses.

## Files
- `lib/metanorma/iso/validate_section.rb`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/normref_structure_rule.rb`.
2. Read `context.root.bibliography.normative`. Check `clause` empty.
3. Spec covers flat normref (skip), normref with subclauses (flag).
4. Delete `normref_validate`.

## Acceptance
- Spec green; ISO_24 still flagged; rice log unchanged.
