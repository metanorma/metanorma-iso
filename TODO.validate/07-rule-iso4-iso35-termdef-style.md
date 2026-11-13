# 07 — Rule ISO_4, ISO_35: Term-definition style

## Why
`validate.rb:termdef_style` walks every `//term` and:
- ISO_4 (en only): definition starts with `the` or `a`.
- ISO_35 (Cyrillic/Latin scripts): definition ends with `.`.

## Files
- `lib/metanorma/iso/validate.rb:36-50` — current implementation.
- `lib/metanorma/iso_document/terms/iso_term.rb` — term model.

## Plan
1. Create `lib/metanorma/iso/validation/rules/termdef_style_rule.rb` with two
   private check methods.
2. Use `Base#descendants(context.root)` to find all `Term` instances.
3. For each term, use `term.definition.text` (typed access).
4. Spec covers en + Cyrl Latn scripts; both Article and FullStop cases.
5. Delete `termdef_style` and `termdef_warn`.

## Acceptance
- Spec green; existing ISO_4/ISO_35 spec passes; rice log unchanged.

## RNG counterpart
None — style check is not encoded in RNG.
