# 12 — Rule ISO_16: Subpart only on IEC documents

## Why
`validate_title.rb:title_subpart_validate` flags subpart on non-IEC docs.

## Files
- `lib/metanorma/iso/validate_title.rb` — current implementation.

## Plan
1. Create `lib/metanorma/iso/validation/rules/title_subpart_rule.rb`.
2. Check `bibdata.docidentifier.publisher` for IEC; if not IEC and subpart
   present, flag ISO_16.
3. Spec covers IEC with subpart (skip), ISO with subpart (flag), ISO without
   subpart (skip).
4. Delete `title_subpart_validate`.

## Acceptance
- Spec green; ISO_16 case still flagged; rice log unchanged.
