# 057: Master Audit — DOCX Output vs Reference (rice.docx)

Comprehensive comparison of `data/rice-dis-output-latest.docx` vs `spec/examples/rice.docx`.

## Summary Statistics

| Metric | Reference | Output | Delta |
|--------|-----------|--------|-------|
| Body paragraphs | 349 | 291 | **-58** |
| Section breaks (inline) | 2 | 2 | 0 |
| Tables | 6 | 3 | **-3** |
| Images (pict) | 5 | 0 | **-5** |
| Images (drawing) | 0 | 2 | +2 |
| Bookmarks | 293 | 98 | **-195** |
| Hyperlinks | 120 | 75 | **-45** |
| Footnotes | 10 | 16 | +6 |
| TOC entries | 26 | 0 | **-26** |
| Unique pStyles | 34 | 40 | +6 |
| Unique rStyles | 30+ | 1 | **-29** |

## Critical Issues (document won't open / fundamental structure broken)

### 058: Missing Cover Page Section Headers/Footers
The cover page sectPr has ZERO headerReference/footerReference elements. Reference has 3 (1 header, 2 footer). Word requires valid header/footer refs for every section. **Likely cause of "file won't open".**

### 059: Missing ALL Annex Headings (A-E)
All 5 annex title paragraphs are missing. Document jumps from Clause 9 to "A.1 Principle" with no "Annex A (normative) Determination of defects" heading. Annexes C, D, E headings are completely absent.

## High Priority Issues

### 060: Missing TOC
Reference has 26 TOC entries with TOC1/2/3 styles and fldChar field codes. Output has empty "Contents" heading only.

### 061: Cover Page Structure Differences
- Missing TC/SC info, stage badge, document number
- Copyright block incorrectly merged into cover page
- Different title layout and style names

### 063: Pervasive Whitespace Issues
- Double spaces in SOURCE references, note text, definition text
- Leading whitespace on paragraphs
- 23 extra `<w:br>` elements where reference has 13
- Trailing whitespace on code blocks

### 064: Missing Section Breaks for Annexes/Bibliography
No page breaks between annexes or before bibliography. Content runs together.

### 067: Missing rStyle (Run-Level Styles)
Output uses only `Hyperlink` rStyle. Reference uses 30+ semantic rStyles for math, cross-references, footnote refs, note labels, etc.

### 068: Missing Figures, Images, and Content
- 3 missing tables (output has 3 vs reference 6)
- Missing figure content (Key paragraphs, sub-figure descriptions)
- Missing Annex D table data
- Missing Annex E heading

## Medium Priority Issues

### 062: Footnote Deduplication
8 separate footnotes with identical "Withdrawn." text should share 1 footnote ID. 2 "Under preparation..." footnotes should share 1 ID.

### 065: Missing Normative Reference Preamble
Terms section missing "For the purposes of this document..." and "ISO and IEC maintain terminology databases..." text.

### 066: Body sectPr Differences
Extra headerReferences, extra titlePg, extra w:code="9" on pgSz.

### 069: Normative Reference Formatting
Missing footnote `)` markers in normref entries. Different style names (RefNorm vs normref).

### 070: Missing Bookmarks and Hyperlinks
-195 bookmarks and -45 hyperlinks missing. Cross-reference navigation degraded.

## Low Priority Issues

### 072: Missing Comments Support
Reference has comment files; output has none.

## Aggregate

### 071: Paragraph Count Mismatch (291 vs 349)
The 58-paragraph deficit is the sum of all individual issues above.

## Priority Order for Fixes

1. **058** — Cover sectPr refs (CRITICAL: may prevent opening)
2. **059** — Annex headings (CRITICAL: fundamental structure)
3. **064** — Section breaks for annexes/biblio
4. **063** — Whitespace cleanup
5. **060** — TOC generation
6. **067** — rStyle assignments
7. **068** — Missing figures/tables/content
8. **061** — Cover page structure
9. **062** — Footnote dedup
10. **065** — Missing preamble text
11. **066** — Body sectPr cleanup
12. **069** — Normref formatting
13. **070** — Bookmarks/hyperlinks
14. **072** — Comments support
