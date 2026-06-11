# Fix 2: Add proper structure to separator footnote paragraphs

## Status: DONE

## Changes
- `uniword/docx/reconciler.rb`: Added `separator_paragraph` helper with spacing properties and empty run
- Updated `separator_entry` and `continuation_entry` to use `separator_paragraph`

## Specs
- "creates separator footnotes with proper paragraph spacing" — PASS
