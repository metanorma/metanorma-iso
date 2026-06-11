# Full Audit: rice_fixed16.docx vs rice_fixed16-repaired.docx

Date: 2026-05-27
Files: `data/rice_fixed16.docx` (ours, 46192 bytes) vs `data/rice_fixed16-repaired.docx` (Word-repaired)
Method: DOM-level semantic comparison (not line-by-line). Styles compared by ID, not position.

---

## Verification Baseline (carried from rice_fixed14 audit)

- **Re-zip test passes**: Word's repaired XML re-zipped with rubyzip opens without error. ZIP packaging is fine; issue is in XML CONTENT.
- **All XML parts parse in strict mode**: No malformed XML.
- **No duplicate IDs**: styles (312 unique), numId (19), abstractNumId (15), footnotes (24), bookmarks (104 start = 104 end), div IDs (71).
- **No broken cross-references**: All rIds internally consistent within each file.
- **No illegal control characters** in any XML part.
- **No BOM** in any XML file (all start with `<?xml`).
- **XML declarations identical**: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` on all parts.
- **Same ZIP entries**: 16 files, identical paths, no missing or extra parts. All use deflate compression.

---

## ZIP Entry Inventory

| Entry | Ours (bytes) | Repaired (bytes) | Notes |
|---|---|---|---|
| `[Content_Types].xml` | 2010 | 1965 | Override ordering |
| `_rels/.rels` | 599 | 590 | Minor size diff |
| `docProps/app.xml` | 1118 | 724 | HeadingPairs stripped |
| `docProps/core.xml` | 723 | 747 | Different timestamps |
| `word/_rels/document.xml.rels` | 1506 | 1471 | **Non-sequential rIds** |
| `word/document.xml` | 174199 | 119917 | Pretty-printed vs single-line |
| `word/endnotes.xml` | 3276 | 3152 | Pretty-printed vs single-line |
| `word/fontTable.xml` | 6105 | 5489 | SimSun usb0 |
| `word/footer1.xml` | 2785 | 2762 | Pretty-printed vs single-line |
| `word/footnotes.xml` | 9102 | 8120 | Pretty-printed vs single-line |
| `word/header1.xml` | 2784 | 2761 | Pretty-printed vs single-line |
| `word/numbering.xml` | 25625 | 21433 | Pretty-printed vs single-line |
| `word/settings.xml` | 11714 | 10769 | Zoom, rsid count |
| `word/styles.xml` | 152341 | 129338 | Pretty-printed vs single-line |
| `word/theme/theme1.xml` | 11451 | 8333 | Pretty-printed vs single-line |
| `word/webSettings.xml` | 39327 | 29028 | Pretty-printed vs single-line |

Our files are consistently larger because we produce pretty-printed (indented) XML while Word saves single-line XML (all content on one line).

---

## Category A: Formatting / Serialization (NOT causing errors)

### A1. Pretty-printed vs single-line XML
Word saves ALL XML parts as single-line (1 line per file). Our output is pretty-printed (hundreds to thousands of lines).
- **Impact**: None. XML parsers treat whitespace between elements as insignificant. All content is identical after whitespace normalization.

### A2. Namespace declaration ordering on root elements
All 10 XML parts have different `xmlns:*` declaration ordering on the root element. Ours puts `xmlns:w` first; repaired puts `xmlns:wpc` first (or other prefixes).
- **Impact**: None. XML namespace declarations are unordered.

### A3. Attribute ordering on `<w:p>` elements
Ours puts `w:rsidR` before `w14:paraId`; repaired puts `w14:paraId` first. Affects all paragraphs across all parts.
- **Impact**: None. XML attribute order is not significant.

### A4. `[Content_Types].xml` — Override entry ordering
Different ordering of `<Override>` elements. Same entries, same content types, same count.
- **Impact**: None. Order doesn't matter.

---

## Category B: Content Changes Word Makes During Save (NOT errors in our XML)

### B1. document.xml — `<w:lastRenderedPageBreak/>`
- Ours: 0 elements
- Repaired: 16 elements (Word adds these during save)
- **Impact**: None. These are caching hints for page layout, not structural.

### B2. document.xml — Run consolidation
- Ours: 1285 `<w:r>` elements
- Repaired: 792 `<w:r>` elements (Word merges 493 adjacent runs, 38% reduction)
- All text content is **IDENTICAL** (19623 characters).
- **Impact**: None. Word consolidates adjacent runs with compatible formatting.

### B3. document.xml — Two adjacent tables merged
- Ours: 2 adjacent `<w:tbl>` (19 rows + 10 rows = 29 total)
- Repaired: 1 `<w:tbl>` (29 rows)
- Table cell text content is **IDENTICAL**.
- **Impact**: None. Word merges directly adjacent tables during save.

### B4. document.xml — `<w:b/>` removal
- Ours: 5 `<w:b/>` (bold) elements
- Repaired: 0 (Word removes redundant bold markers)
- **Impact**: None. `<w:b/>` without val defaults to true. Valid OOXML.

### B5. document.xml — Hyperlink text splitting
All 60 hyperlinks have identical text content and anchors. Word consolidates adjacent runs within hyperlinks.
- **Impact**: None.

### B6. app.xml — HeadingPairs / TitlesOfParts stripped
- Ours: Has `<HeadingPairs>` and `<TitlesOfParts>` with vt:vector elements
- Repaired: Does NOT have these elements
- **Impact**: LOW. Document metadata; Word strips during save.

---

## Category C: Low-Significance Differences

### C1. settings.xml — Zoom attribute
- Ours: `<w:zoom w:val="bestFit" w:percent="160"/>`
- Repaired: `<w:zoom w:percent="104"/>` (no `w:val` attribute)
- **Impact**: LOW. Zoom is a UI hint. `bestFit` is valid OOXML but Word replaces it during save.

### C2. settings.xml — rsid count
- Ours: 74 rsid entries
- Repaired: 78 rsid entries (Word adds 4 during save)
- **Impact**: LOW. Cosmetic metadata.

### C3. fontTable.xml — SimSun sig usb0
- Ours: `w:usb0="00000003"`
- Repaired: `w:usb0="00000203"`
- **Impact**: LOW. Font signature metadata. Word may update based on installed fonts.

### C4. core.xml — Timestamps
- Different creation/modification dates. Expected.

---

## Category D: Potentially Significant Differences (Investigate)

### D1. word/_rels/document.xml.rels — Non-sequential rIds
**THIS IS THE MOST SUSPICIOUS DIFFERENCE.**

Ours has non-sequential relationship IDs:
```
rId1:  numbering.xml
rId2:  styles.xml
rId3:  settings.xml
rId4:  webSettings.xml
rId13: fontTable.xml     ← gap: rId5-rId12 missing
rId14: theme/theme1.xml
rId15: header1.xml
rId16: footer1.xml
rId17: footnotes.xml
rId18: endnotes.xml
```

Repaired (Word normalized to sequential):
```
rId1:  numbering.xml
rId2:  styles.xml
rId3:  settings.xml
rId4:  webSettings.xml
rId5:  footnotes.xml     ← renumbered sequential
rId6:  endnotes.xml
rId7:  header1.xml
rId8:  footer1.xml
rId9:  fontTable.xml
rId10: theme/theme1.xml
```

Cross-reference check: document.xml only uses rId15 (header) and rId16 (footer) directly — both are defined. No broken references internally.

**However**: The rId gap (rId5-rId12 missing) means the template's original relationships were stripped but the numbering wasn't resequenced. Word renumbers to rId1-rId10 during repair.

**Fix needed**: Re-number relationships sequentially starting from rId1.

### D2. styles.xml — DefaultParagraphFont position changed
Our reconciler's rebuild of DefaultParagraphFont (delete + re-add with semiHidden) moved it from position 7 to position 311 (end of collection):
- Ours: DefaultParagraphFont at index 311 (last style)
- Repaired: DefaultParagraphFont at index 7

All 312 styles are **IDENTICAL** when compared by ID after sorting attributes. Zero content or structural differences within any individual style.

The OOXML spec doesn't specify style ordering requirements. However, Word consistently places DefaultParagraphFont near the beginning (after Normal, Heading1-6).

**Fix needed**: Ensure DefaultParagraphFont stays at its original position, or re-order styles to match Word's expected order.

---

## Category E: Verified Identical (after normalization)

These parts have NO differences beyond namespace/attribute ordering:

| Part | Status |
|---|---|
| `_rels/.rels` | **IDENTICAL** |
| `docProps/core.xml` | IDENTICAL (after timestamp normalization) |
| `word/theme/theme1.xml` | **IDENTICAL** |
| `word/endnotes.xml` | IDENTICAL (namespace ordering only) |
| `word/footnotes.xml` | IDENTICAL (namespace/attr ordering only) |
| `word/header1.xml` | IDENTICAL (namespace/attr ordering only) |
| `word/footer1.xml` | IDENTICAL (namespace/attr ordering only) |
| `word/numbering.xml` | IDENTICAL (namespace ordering only) |
| `word/webSettings.xml` | IDENTICAL (namespace ordering only) |
| `word/settings.xml` | IDENTICAL element ordering (26 children, same sequence) |
| `word/styles.xml` | **312/312 styles IDENTICAL** (after attribute sorting) |
| `word/document.xml` | **Text content IDENTICAL** (19623 chars) |

---

## Summary

After exhaustive DOM-level semantic comparison:

1. **Text content**: IDENTICAL across all XML parts
2. **Styles**: 312/312 identical after attribute normalization. Zero structural differences.
3. **Settings element ordering**: IDENTICAL (26 children, same sequence)
4. **Footnotes/endnotes**: IDENTICAL
5. **Hyperlinks**: IDENTICAL (60 links, same anchors, same text)
6. **Bookmarks**: 104 starts = 104 ends, all matched
7. **Tables**: Cell text IDENTICAL (only merge difference)
8. **Relationships (.rels)**: Internally consistent, no broken references

### Root cause hypothesis (priority order):

1. **D1: Non-sequential rIds in document.xml.rels** (HIGH priority)
   - rId1-rId4 then jump to rId13-rId18. Gap of rId5-rId12.
   - Word repairs by renumbering to sequential rId1-rId10.
   - This is the most suspicious difference.

2. **D2: DefaultParagraphFont moved to end of styles** (MEDIUM priority)
   - Position 311 instead of 7.
   - Caused by reconciler's delete+re-add approach.

3. **If D1 and D2 don't fix it**: Investigate XML serialization details
   - Element ordering within complex types beyond what we've checked
   - Whitespace within element content (not between elements)
   - Attribute value validation beyond structural checks

### Action items:

- [ ] Fix D1: Re-number relationship IDs sequentially in document.xml.rels
- [ ] Fix D2: Keep DefaultParagraphFont at original position instead of delete+re-add
- [ ] Generate rice_fixed17.docx with both fixes
- [ ] Test in Word
