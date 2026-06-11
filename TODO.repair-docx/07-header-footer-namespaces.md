# TODO 07: Header/Footer missing namespace declarations (ALREADY FIXED)

## Problem
Header and Footer XML parts had no extension namespace declarations and no
`mc:Ignorable` attribute. Word requires all root elements to declare the full
set of extension namespaces used by the document.

## Already Fixed
- Added full `namespace_scope` block with `declare: :always` to `Header` and `Footer`
  models in `uniword/wordprocessingml/header.rb` and `footer.rb`
- Added `mc_ignorable` attribute with mapping
- Reconciler sets `mc_ignorable` with all extension prefixes including `wp14`

## Verification
- header1.xml should have `xmlns:w14`, `xmlns:w15`, etc. and `mc:Ignorable="w14 w15 ..."`
- footer1.xml should have the same
