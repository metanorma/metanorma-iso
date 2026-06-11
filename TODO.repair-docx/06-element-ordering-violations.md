# TODO 06: Element ordering violations (DONE)

## Problem
OOXML has strict element ordering requirements. Schema violations trigger
"unreadable content" in Word.

## Fixed
- **numPr**: `ilvl` now comes before `numId` — fixed in
  `uniword/properties/numbering_properties.rb`
- **pBdr**: borders now in order top, left, bottom, right — fixed in
  `uniword/properties/borders.rb`
- **sectPr**: headerReference/footerReference now before pgSz/pgMar — fixed in
  `uniword/wordprocessingml/section_properties.rb`
- **tcPr before p in table cells**: TableCellBuilder tracks element_order to
  ensure tcPr comes before p — fixed in `uniword/builder/table_cell_builder.rb`
- **Paragraph mixed content**: Runs, hyperlinks, bookmarks now serialized in
  document order (not grouped by type) — fixed in
  `uniword/builder/paragraph_builder.rb`

## Verification
- All builder specs pass
- All reconciler specs pass
- Generated DOCX has correct element ordering in numPr, pBdr, sectPr, tc, p
