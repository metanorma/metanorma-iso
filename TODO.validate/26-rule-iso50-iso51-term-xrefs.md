# 26 — Rule ISO_50, ISO_51: Term cross-references

## Why
- ISO_50: cross-referencing terms clauses from wrong context.
- ISO_51: xref to terms section from a non-terms clause.

## Files
- `lib/metanorma/iso/validate_xref.rb:term_xrefs_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/term_xrefs_rule.rb`.
2. Use `closest_ancestor` walker to determine the context of each xref.
3. Check whether xref targets a term from outside terms clauses.
4. Spec covers both cases.
5. Delete `term_xrefs_validate`.

## Risk
Needs `closest_ancestor` helper in Base.

## Acceptance
- Spec green; ISO_50/51 still flagged; rice log unchanged.
