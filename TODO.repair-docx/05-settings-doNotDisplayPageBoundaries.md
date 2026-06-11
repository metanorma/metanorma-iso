# TODO 05: Settings.xml missing doNotDisplayPageBoundaries (DONE)

## Problem
Word adds `<w:doNotDisplayPageBoundaries/>` to settings.xml during repair.
Our output didn't have this element even though the reconciler was adding it.

## Root Cause
The reconciler sets `settings.do_not_display_page_boundaries` to a new instance,
but the Settings model uses `mixed_content` which drives serialization via
`element_order`. When parsed from the template DOCX, `element_order` contains
only the elements present in the template — the newly added attribute is not in
`element_order` and gets silently skipped during serialization.

Additionally, `lutaml-model 0.8.7` (the version in use) does NOT clear
`element_order` in `clear_xml_parse_state!` (that was only added in 0.8.9).

## Fix
- **Reconciler** (`uniword/docx/reconciler.rb`): Added `ensure_element_in_order`
  helper that injects a named element into a mixed_content model's `element_order`.
  Used in `reconcile_settings` to add `doNotDisplayPageBoundaries` after `zoom`.

## Verification
- `settings.xml` contains `<w:doNotDisplayPageBoundaries/>` after `<w:zoom>`
- All 50 reconciler specs pass
- All 150 adapter specs pass
