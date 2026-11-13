# 23 — Rule ISO_21, ISO_22: Unreferenced assets

## Why
- ISO_21: unreferenced annex/table/figure.
- ISO_22: unreferenced formula.

## Files
- `lib/metanorma/iso/validate_xref.rb:xrefs_mandate_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/unreferenced_assets_rule.rb`.
2. Collect all anchor targets via `Base#each_anchored(root)`; collect all
   xrefs/erefs via walking inline content. Compute unreferenced set.
3. For each unreferenced asset, emit ISO_21 or ISO_22 (formula) with the
   asset type and ID.
4. Spec covers unreferenced annex, table, figure, formula.
5. Delete `xrefs_mandate_validate`.

## Risk
Depends on SharedState being populated. Coordinate with TODO 30.

## Acceptance
- Spec green; ISO_21/22 still flagged; rice log unchanged.
