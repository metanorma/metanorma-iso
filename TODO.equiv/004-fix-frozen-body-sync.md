# TODO 004: Fix FrozenError in element_order manipulation

## Status: DONE

## Problem
`element_order` arrays from lutaml-model XML parsing are frozen. Three code paths tried to mutate them with `<<` and `insert`, causing `FrozenError: can't modify frozen Array` when serializing documents loaded from existing DOCX files.

Affected locations:
- `body.rb:87` — `sync_element_order` appends missing entries
- `reconciler/helpers.rb:88,91,93` — `ensure_element_in_order` inserts entries
- `reconciler/helpers.rb:104` — `insert_element_order` inserts entries

12 integration specs failed due to this.

## Fix
All three paths now build a mutable copy via `Array#dup` before mutation:
- `body.rb`: builds `new_entries` array, uses `self.element_order = element_order + new_entries`
- `helpers.rb`: added `thaw_and_insert` / `thaw_and_append` helpers that use `model.element_order =` (lutaml-model provides `attr_accessor :element_order`)

## Files Changed
- `uniword/lib/uniword/wordprocessingml/body.rb` — sync_element_order builds new array, uses setter
- `uniword/lib/uniword/docx/reconciler/helpers.rb` — thaw_and_insert / thaw_and_append helpers

## Verification
- 204 specs (docx + previously-failing integration) pass with 0 failures
