# TODO 050: Fix Footnote Deduplication — Wrong IDs in Bibliography

## Status: DONE

## What

Footnotes in bibliography entries reuse the same IDs (FN1, FN2) as normative reference footnotes. The reference assigns unique IDs to each section's footnotes (normative refs use FN1-FN2, bibliography uses FN7-FN10).

## Why

### Reference Footnotes
```
fn 1: Withdrawn.                              (normative refs: ISO 712, ISO 16634)
fn 2: Under preparation. (Stage at ISO/DIS)    (normative refs: ISO 16634)
fn 3: Withdrawn.                              (body: ISO 712)
fn 4: Formerly denoted as 15 % (m/m).         (body: Table 1)
fn 5: Under preparation. (Stage at ISO/DIS)    (body: ISO 16634)
fn 6: Lugols is an example...                 (Annex B)
fn 7: Cancelled and replaced by ISO 2146:2010 (Biblio: ISO 2146)
fn 8: Withdrawn.                              (Biblio: ISO 5725-1)
fn 9: Withdrawn.                              (Biblio: ISO 5725-2)
fn 10: Withdrawn.                             (Biblio: ISO 7301)
```

### Our Output Footnotes
```
fn 1: Withdrawn.                              (normative refs AND bibliography share this!)
fn 2: Under preparation. (Stage at ISO/DIS)    (normative refs AND body share this!)
fn 3: Formerly denoted as 15 % (m/m).
fn 4: Organic extraneous matter...            (table footnote — should be same as fn 6 in ref?)
fn 5: Inorganic extraneous matter...
fn 6: The maximum permissible mass fraction...
fn 7: Lugols is an example...
fn 8: Parboiled rice.
```

### Key Issues

1. **Footnotes deduplicated across sections**: FN1 "Withdrawn." is shared between normative refs (ISO 712:2009) and bibliography (ISO 5725-1:1994, ISO 5725-2:1994, ISO 7301:2011). In the reference, these get SEPARATE footnote numbers because footnotes are scoped per-section or per-page.

2. **Missing footnotes**: Our output only has 8 footnotes vs 10 in the reference. Some are being improperly merged.

3. **The deduplication cache is global**: The `@footnote_content_cache` in InlineRenderer deduplicates across the ENTIRE document. But ISO documents use per-page or per-section footnote numbering. "Withdrawn." should be a separate footnote each time it appears in a different context.

### Root Cause

The footnote deduplication implemented in TODO 043 uses a global content cache. This incorrectly merges footnotes that have the same text but appear in different sections of the document.

## Architecture

1. **Remove global deduplication**: Footnotes should NOT be deduplicated by content across the entire document
2. **Table-level deduplication**: Within a single table, duplicate footnotes should share the same number (the table in 4.2 has the same footnote text in multiple cells)
3. **Approach**: Clear the footnote cache when exiting table context, but keep it within table context

Alternatively, the reference rice.docx may actually have 10 unique footnotes because the old isodoc pipeline creates a new footnote for each reference, even with identical text. The deduplication we implemented is too aggressive.

The user specifically asked for deduplication of table footnotes (same defect text in multiple table cells). This is different from bibliography footnotes that happen to have the same text.

## Files

- `lib/isodoc/iso/docx/inline.rb` — `render_footnote`, `@footnote_content_cache`
- `lib/isodoc/iso/docx/adapter.rb` — `visit_table` context

## Depends On

- None
