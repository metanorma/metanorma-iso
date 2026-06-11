# TODO 10: Duplicate bookmark names in document.xml (DONE)

## Problem
Broken output has 17 duplicate `w:name` values on `<w:bookmarkStart>` elements.
OOXML requires bookmark names to be unique within a document. Word strips the
duplicates during repair.

Duplicate names (each appears twice with different IDs):
- `ISO7301`, `ISO6322-1`, `ISO6322-2`, `ISO6322-3`, `ISO5725-1`, `ISO5725-2`
- `ISO3696`, `ISO2146`, `ISO14864`, `IEC61010-2`
- `ref10`, `ref11`, `ref12`, `ref13`, `ref14`, `ref15`, `ref16`

All duplicates are in `BiblioEntry`-styled paragraphs. The adapter generates
bibliography entries twice (once as hidden/undisplayed, once as visible),
creating duplicate bookmarks with the same name but different IDs.

Repaired output has 0 duplicates — Word strips the second occurrence.

## Root Cause
`visit_references_section` in the adapter processed bibliography items twice:
1. Explicitly via `refs_sect.references&.each { |r| visit_bibliographic_item(r, doc) }`
2. Again via `walk_mixed_content(refs_sect, doc)` which traverses `element_order`
   and encounters each `bibitem` again

This created duplicate `BiblioEntry` paragraphs with the same bookmark name
but different IDs.

## Fix
- **Adapter** (`lib/isodoc/iso/docx/adapter.rb`): Removed explicit
  `refs_sect.references` iteration from `visit_references_section`. Now relies
  solely on `walk_mixed_content` to traverse bibliography items through
  `element_order`.

## Verification
- 0 duplicate bookmark names in document.xml (was 17)
- Bookmark count: 104 (was 121)
- BiblioEntry paragraphs: 24 (was 41, correctly halved)
- All 630 metanorma-iso specs pass
- DOCX opens in Word without "unreadable content" repair dialog

## Verification
- `grep 'bookmarkStart' word/document.xml | grep 'name=' | sed 's/.*name="//' | sed 's/".*//' | sort | uniq -c | grep -v '1 '` should return nothing
