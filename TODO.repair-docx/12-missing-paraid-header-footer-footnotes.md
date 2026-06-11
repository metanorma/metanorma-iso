# TODO 12: Missing paraId/textId on header/footer/footnote paragraphs (COSMETIC)

## Problem
Header, footer, and footnote paragraphs are missing `w14:paraId`, `w14:textId`,
`w:rsidR`, and `w:rsidRDefault` attributes. Broken output has bare `<w:p>`;
repaired output adds these attributes.

## Status
DONE. Added `backfill_part_paragraphs` and `backfill_note_paragraphs` to the
reconciler. These methods backfill paraId, textId, and rsidR on all paragraphs
in headers, footers, footnotes, and endnotes.

## Fix Location
- **Uniword reconciler** (`reconciler.rb`): `backfill_part_paragraphs`,
  `backfill_note_paragraphs` called from `reconcile_headers_footers`,
  `reconcile_footnotes`, `reconcile_endnotes`
