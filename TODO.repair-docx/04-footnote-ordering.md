# TODO 04: Footnote content ordering mismatch (ADAPTER ISSUE)

## Problem
Our footnotes.xml has footnote content in different order than Word's repaired
version. The IDs match but the text content at each position is swapped.

## Status
DONE. Fixed in Uniword reconciler — `reorder_notes_by_reference` scans the
document body for footnote/endnote references in reading order and reorders
the entries to match. Called from `reconcile_footnotes` and `reconcile_endnotes`.

This does NOT trigger "unreadable content" — it was a content accuracy issue.

## Fix Location
- **Uniword reconciler** (`reconciler.rb`): added `reorder_notes_by_reference`,
  `collect_note_reference_order`, `walk_body_paragraphs`, `walk_table_paragraphs`
