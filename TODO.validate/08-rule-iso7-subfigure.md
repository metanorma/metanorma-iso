# 08 — Rule ISO_7: Subfigure contents

## Why
`validate.rb:subfigure_validate` rejects footnotes, notes, keys inside nested
figures (`//figure//figure`).

## Files
- `lib/metanorma/iso/validate.rb:73-82` — current implementation.
- `lib/metanorma/iso_document/blocks/` — figure model.

## Plan
1. Create `lib/metanorma/iso/validation/rules/subfigure_rule.rb`.
2. Walk figures recursively: `each_figure(root).flat_map { |f| f.figures }`
   yields nested figures. For each nested figure, check `footnotes`, `notes`,
   `keys` collections.
3. Spec uses real Figure instances built via the model.
4. Delete `subfigure_validate`.

## Acceptance
- Spec green; ISO_7 case still flagged; rice log unchanged.
