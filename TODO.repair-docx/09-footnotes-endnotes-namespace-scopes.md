# TODO 09: Missing namespace declarations on footnotes/endnotes root elements (DONE)

## Problem
`footnotes.xml` and `endnotes.xml` had namespace prefixes (`w16du`, `w16sdtfl`)
listed in `mc:Ignorable` but NOT declared as `xmlns:` attributes on the root
element. This is an XML namespace violation that triggers Word's "unreadable
content" repair dialog.

The `Footnotes` and `Endnotes` models had no `namespace_scope` declarations,
so lutaml-model only serialized namespaces actually used in the content. But the
reconciler set `mc_ignorable` to include ALL extension prefixes, creating a
mismatch where `mc:Ignorable` referenced undeclared prefixes.

## Fix
- **Footnotes model** (`uniword/wordprocessingml/footnotes.rb`): Added full
  `namespace_scope` declarations matching `DocumentRoot` and `Header`.
- **Endnotes model** (`uniword/wordprocessingml/endnotes.rb`): Same.
- **Reconciler** (`uniword/docx/reconciler.rb`): Added `package.footnotes` and
  `package.endnotes` to `clear_stored_namespace_plans` so parsed objects get
  their namespace plans cleared for `declare: :always` to take full effect.

Also fixed:
- **Missing `<w:cols>` in sectPr**: Reconciler now backfills `Columns.new(space: 720)`
  when section properties exist but lack columns (previously only added columns
  when creating entirely new section properties).

## Verification
- `mc:Ignorable` prefixes in footnotes.xml/endnotes.xml are all declared as namespaces
- `<w:cols w:space="720"/>` present in sectPr
- All 1990 uniword specs pass (1 pre-existing cosmetic failure)
- All 630 metanorma-iso specs pass
