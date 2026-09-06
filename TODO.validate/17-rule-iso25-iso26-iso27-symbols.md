# 17 — Rule ISO_25, ISO_26, ISO_27: Symbols section rules

## Why
- ISO_25: multiple symbols sections.
- ISO_26: non-dl content in symbols section.
- ISO_27: symbols outside annex in vocab documents.

## Files
- `lib/metanorma/iso/validate_section.rb:symbols_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/symbols_rule.rb`.
2. Walk annexes for `definitions[@type='symbols']`. Check:
   - At most one (ISO_25).
   - All children are `<dl>` (ISO_26).
   - In vocab docs, symbols sections must be in annexes (ISO_27).
3. Spec covers each of the three failure modes.
4. Delete `symbols_validate`.

## Acceptance
- Spec green; ISO_25/26/27 still flagged; rice log unchanged.
