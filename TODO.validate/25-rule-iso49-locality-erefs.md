# 25 — Rule ISO_49: Locality in erefs to undated ISO/IEC

## Why
`validate_xref.rb:locality_erefs_validate` flags undated ISO/IEC references
that cite specific elements (clauses, tables) — undated refs cannot have
locality.

## Files
- `lib/metanorma/iso/validate_xref.rb:locality_erefs_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/locality_erefs_rule.rb`.
2. Walk all erefs. For each, check if bibitem is ISO/IEC + undated + has
   locality.
3. Spec covers dated with locality (skip), undated ISO without locality
   (skip), undated ISO with locality (flag).
4. Delete `locality_erefs_validate`.

## Acceptance
- Spec green; ISO_49 still flagged; rice log unchanged.
