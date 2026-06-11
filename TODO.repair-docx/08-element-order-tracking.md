# TODO 08: Programmatic paragraph/cell element_order tracking (DONE)

## Problem
When paragraphs and table cells are created programmatically (via builders),
`element_order` is nil/empty. For `mixed_content` models, the serializer falls
back to `map_element` declaration order, which groups all runs together, then
all hyperlinks, then all bookmarks. OOXML requires interleaved order.

From diff: 58 hyperlinks serialized after all runs, 80 bookmark mismatches,
84 tcPr-before-p violations.

## Root Cause
ParagraphBuilder#<< added elements to collections (runs, hyperlinks, bookmarks)
without updating `element_order`. lutaml-model uses `element_order` to drive
serialization for `mixed_content` models. When nil/empty, it uses map_element
order (all runs, then all hyperlinks, then all bookmarks) — wrong for OOXML.

Same issue in TableCellBuilder — content added without element_order tracking.

## Fix
- **ParagraphBuilder#<<**: Added `track_element_order(tag)` calls for runs,
  hyperlinks, bookmarkStart, bookmarkEnd, SDTs. Added `ensure_properties_in_order`
  to inject "pPr" at element_order start when properties exist.
- **TableCellBuilder#<<**: Same pattern — track "p"/"tbl" in element_order,
  ensure "tcPr" first when properties exist.
- **DocumentBuilder#bookmark**: Changed to use `para <<` instead of direct model
  access, so bookmarks are tracked in element_order.
- **Reconciler `empty_run?`**: Expanded to check ALL content-carrying attributes
  (break, tab, drawings, pictures, alternate_content, footnote_reference,
  endnote_reference, field_char, instr_text, position_tab, del_text,
  no_break_hyphen, sym, last_rendered_page_break). Previously only checked
  `text`, which stripped runs containing page breaks, watermarks, etc.

## Verification
- 485 builder specs pass (was 9 failures before fix)
- 5545 uniword specs pass (1 pre-existing cosmetic failure)
- 630 metanorma-iso specs pass
- Paragraphs with mixed content serialize in correct OOXML order
