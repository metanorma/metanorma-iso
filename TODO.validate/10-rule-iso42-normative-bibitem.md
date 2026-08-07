# 10 — Rule ISO_42: Normative non-ISO/IEC bibitem

## Why
`validate_section.rb:norm_bibitem_style` flags normative references to
non-ISO/IEC publishers (allowed only with conditions per ISO/IEC DIR 2 10.2).

## Files
- `lib/metanorma/iso/validate_section.rb` — current implementation.
- `lib/metanorma/iso_document/sections/` — bibliography section.

## Plan
1. Create `lib/metanorma/iso/validation/rules/normative_bibitem_rule.rb`.
2. Walk `context.root.bibliography.normative.bibitem` (verify path).
3. For each bibitem, check publisher. Allowed publishers: ISO, IEC, combined
   forms. Flag others with ISO_42.
4. Spec covers ISO (skip), IEC (skip), ISO/IEC (skip), other (flag).
5. Delete `norm_bibitem_style`.

## Acceptance
- Spec green; ISO_42 case still flagged; rice log unchanged.
