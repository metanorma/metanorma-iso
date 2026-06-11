# TODO 017: Fix Table Notes and Footnotes

## Status: COMPLETED

- Added `render_table_notes` to `visit_table` — renders `table.note` children
  as Note-styled paragraphs after the table
- Uses existing `visit_note` method for consistent note rendering
- Table footnotes (fn inside table cells) handled by inline renderer dispatch
