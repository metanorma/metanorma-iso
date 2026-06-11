# 107: Master Audit Update (v2) — DOCX Output vs Reference

## Status: Significant progress, file is structurally valid

The DOCX is now valid OOXML, no broken references, all style references resolve. The file may have a Word-specific issue, but Ruby/Uniword can parse it without errors.

## Comprehensive Analysis

### Validation checks
- ZIP structure: Valid, 27 entries
- document.xml: Valid XML (Nokogiri strict parse OK)
- Content_Types: All overrides match existing files
- Styles: All 39 pStyles + 12 rStyles are defined
- Numbering: All numId references are defined
- Footnotes: All footnote IDs 1-8 are defined
- Hyperlinks: 69 with anchor (valid), 6 with r:id (valid)
- Section properties: 3 sectPr (cover, front_matter, body)
- All rIds in document.xml.rels point to existing files
- Template core.xml `<dc:title>` cleared to prevent stale data

### Current stats

| Metric | Reference | Output | Delta |
|--------|-----------|--------|-------|
| Body paragraphs | 349 | 304 | **-45** |
| Tables | 6 | 6 | 0 ✓ |
| Bookmarks | 293 | 103 | **-190** |
| Hyperlinks | 120 | 75 | **-45** |
| Footnote refs | 10 | 22 | +12 |
| rStyles | 810 | 186 | **-624** |
| Page breaks | 9 | 6 | -3 |

### Completed Fixes
1. 058: Cover sectPr — clean, no extras
2. 059: All 5 annex headings present
3. 063: Whitespace normalized
4. 064: Page breaks before each annex + bibliography
5. 066: Body sectPr — footer-only refs
6. 067: 12 semantic rStyles added (was only 1)
7. 062: Footnote dedup (16→10 unique)
8. 065: Terms preamble present
9. 068: All 6 tables (was 3)
10. 091: core.xml `<dc:title>` cleared (stale data)
11. 092: Added missing template styles (AltTerms, DeprecatedTerms, normref, etc.)
12. 094: Style mapping uses correct names
13. 095: Cover page restructured (doc number, TC/SC, "Second edition", "CD stage", etc.)
14. 096: Space between annex obligation and title

### Remaining Issues

| # | Issue | Severity | Notes |
|---|-------|----------|-------|
| 097 | Missing 190 bookmarks | HIGH | Headings, terms, figures, tables need bookmarks |
| 098 | "ISO" prefix merged into text | MED | Whitespace handling between elements |
| 100 | Sourcecode formatting (callouts, line breaks) | MED | Need to preserve newlines |
| 101 | Normref `)` footnote markers | MED | Footnote references in bib entries |
| 102 | Formula names not on separate line | LOW | Math rendering needs proper MathML→OMML |
| 103 | Missing rStyles (stem, etc.) | MED | Add proper rStyle application to runs |
| 070 | 45 missing hyperlinks | MED | xref/eref need to generate hyperlinks |
| 093 | 26 missing TOC entries | LOW | Word auto-populates from field instruction |

### Critical (likely "won't open" cause)
- Stale `<dc:title>` in core.xml — **FIXED** (091)
- Missing style definitions — **FIXED** (092)

The "won't open" issue was most likely caused by:
1. Stale `<dc:title>` referencing a different ISO document
2. Missing paragraph style definitions like `AltTerms`, `DeprecatedTerms`, `normref`

Both have been fixed. The file should now open in Word.
