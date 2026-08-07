# 21 — Rule ISO_43: Only-child clause

## Why
`validate_section.rb:onlychild_clause_validate` flags a clause with a single
subclause (should either be flat or have multiple children).

## Files
- `lib/metanorma/iso/validate_section.rb:onlychild_clause_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/only_child_clause_rule.rb`.
2. Recursively walk `sections.clause` and `annex.clause`. For each clause,
   if it has exactly one child clause, flag ISO_43.
3. Spec covers zero children (skip), one child (flag), two+ children (skip).
4. Delete `onlychild_clause_validate`.

## Acceptance
- Spec green; ISO_43 still flagged; rice log unchanged.
