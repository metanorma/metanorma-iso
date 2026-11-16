# 09 — Rule ISO_8: Bibitem unpublished status

## Why
`validate.rb:bibitem_validate` finds `//bibitem[date/on='–']` and warns if no
`<note type="Unpublished-Status">` is present.

## Files
- `lib/metanorma/iso/validate.rb:106-112`.
- `lib/metanorma/iso_document/metadata/` — bibitem model.
- `lib/metanorma/iso_document.rb` (root) → `bibliography` references.

## Plan
1. Create `lib/metanorma/iso/validation/rules/bibitem_unpublished_rule.rb`.
2. Walk `context.root.bibliography.bibitem` (verify path). For each, check
   `date.on` for en-dash and `notes.any? { |n| n.type == "Unpublished-Status" }`.
3. Spec covers: dated bibitem (skip), en-dated with note (skip), en-dated
   without note (flag ISO_8).
4. Delete `bibitem_validate`.

## Acceptance
- Spec green; ISO_8 case still flagged; rice log unchanged.
