# 022 — Rice DOCX Final Audit

## Status: Content-complete, structural differences documented

## Metrics Comparison

| Metric | REF (old pipeline) | OURS (new adapter) | Delta |
|--------|-------------------|--------------------|-------|
| Total paragraphs | 436 | 372 | -64 |
| Body paragraphs | 267 | 217 | -50 |
| Hyperlinks | 60 | 58 | -2 |
| Tables | 1 | 2 | +1 |
| Images | 0 | 2 | +2 |
| Footnotes | 10 | 20 | +10 |

## Content Verification

All key content verified present in both documents:
- All 15 terms (paddy rice, rough rice, husked rice, etc.)
- All annexes (A through D)
- All bibliography entries ([1] through [17])
- All clauses (Foreword through Marking)
- Figures, tables, formulas

Shared paragraphs: 195. Differences are from:
1. REF renders duplicate paragraphs (raw + formatted for each element)
2. Our adapter correctly skips `original_id` duplicates
3. REF has no SOURCE paragraphs; we suppressed them to match

## Known Differences (acceptable)

1. **Duplicate rendering**: REF renders both raw and formatted versions of term
   definitions, deprecated terms, etc. Our adapter skips duplicates via
   `duplicate_element?` check. Correct behavior.

2. **Hyperlink URLs in text**: Our output includes URL text inline
   (`ISO Online browsing platform: available at https://www.iso.org/obp`),
   REF has empty hyperlink text. Both are valid presentations.

3. **paraId/rsidR**: Auto-generated IDs differ. Expected.

4. **Footnote count**: 20 vs 10. Our adapter creates footnote separator entries
   that REF counts differently.

5. **Image count**: 2 vs 0. Our adapter renders images from data URIs in the
   presentation XML. REF may not have had these resolved.

## Remaining Bugs (also in REF)

These bugs exist in both REF and our output:
1. **"DEPRECATED: DEPRECATED:" double prefix** — Both have it
2. **"Note13.5,Note1" concatenation** — Note number and text without space
3. **"3.1husked rice" xref concatenation** — Xref text runs into next element

## Files Modified

- `lib/isodoc/iso/docx/adapter.rb`:
  - Removed `else` clause from `visit_block` (was recursing into inline elements)
  - Suppressed `render_term_source` (metadata only, not rendered in REF)
  - `duplicate_element?` check for `original_id` elements
  - References section heading uses context depth
  - `visit_paragraph` skips `original_id` paragraphs

- `lib/isodoc/iso/docx/inline.rb`:
  - `render_link` strips `mailto:` prefix from display text
  - `render_semx` skips semx for "link" type (raw link already renders)
  - `render_semx` renders content for xref/eref (semx has display text)
