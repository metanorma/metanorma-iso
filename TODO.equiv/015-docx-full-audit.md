# Full Audit: rice_fixed14.docx vs rice_fixed14-repaired.docx

Date: 2026-05-27
Files: `data/rice_fixed14.docx` (ours) vs `data/rice_fixed14-repaired.docx` (Word-repaired)

## Verification Baseline

- **Re-zip test passes**: Word's repaired XML re-zipped with rubyzip opens without error. Proves: ZIP packaging is fine, issue is in XML CONTENT.
- **All XML parts parse in strict mode**: No malformed XML.
- **No duplicate IDs**: styles (312 unique), numId (19), abstractNumId (15), footnotes (24), bookmarks (104 start = 104 end), div IDs (71).
- **No broken cross-references**: All rIds internally consistent in both files.
- **mc:Ignorable**: All ignorable prefixes are properly declared as namespaces on root elements.
- **No illegal control characters** in any XML part.
- **Same ZIP entries**: 16 files, identical paths, no missing or extra parts.

---

## Category A: Cosmetic / Ordering Differences (NOT causing errors)

### A1. Namespace declaration ordering on root elements
**All 10 XML parts** differ only in the order of `xmlns:*` declarations on the root element.
- Ours: `xmlns:w` first, then other prefixes
- Repaired: `xmlns:wpc` first, then other prefixes
- **Impact**: None. XML parsers treat namespace declarations as unordered.

### A2. Attribute ordering on `<w:p>` elements
Ours puts `w:rsidR` before `w14:paraId`; repaired puts `w14:paraId` first.
- **Impact**: None. XML attribute order is not significant.

### A3. `[Content_Types].xml` — Override entry ordering
Different ordering of `<Override>` elements. Same entries, same content types.
- **Impact**: None. Order doesn't matter.

### A4. `<w:lastRenderedPageBreak/>` in document.xml
- Ours: 0 elements
- Repaired: 16 elements (Word adds these during save)
- **Impact**: None. These are caching hints, not structural.

### A5. settings.xml — rsid count
- Ours: 74 rsid entries
- Repaired: 78 rsid entries (Word adds 4 during save)
- **Impact**: None. Cosmetic metadata.

### A6. ZIP entry sizes
All entries in ours are larger (more namespace declarations in our verbose XML). No functional difference.

---

## Category B: Content Differences (Word changed during repair, but NOT errors)

### B1. document.xml — Hyperlink text run splitting
- Ours: Multiple `<w:r>` per hyperlink (e.g., "Annex" + "A" as 2 runs)
- Repaired: Single `<w:r>` per hyperlink ("AnnexA" as 1 run)
- All 60 hyperlinks have **identical text content and anchors**.
- **Impact**: Cosmetic. Word consolidates adjacent runs during save. Not an error.

### B2. document.xml — Two adjacent tables merged
- Ours: 2 adjacent `<w:tbl>` (19 rows + 10 rows = 29 total)
- Repaired: 1 `<w:tbl>` (29 rows)
- Tables are directly adjacent (positions 285, 286 in body) with identical properties.
- **Impact**: Word merges adjacent tables during save. Not an error in our XML.

### B3. styles.xml — Tab stop position differences
Many styles have different tab stop positions (`w:pos` values). Word normalizes tab positions during save.
Affected styles: Heading1-5, h2annex-h5annex, HTMLPreformatted, TOC1, Code, Formula, BaseText, BodyTextCenter, Dimension100, Example0, Exampleindent, FigureGraphic, Note0, Figuresubtitle, KeyText, ListContinue1, ListNumber1, Tablefooter, p2-p6, RefNorm, Noteindent, Noteindent2continued, Noteindent2, a2, a5, a6, zzCopyright.
- **Impact**: Layout/rendering difference only. Not a structural error.

### B4. styles.xml — DefaultParagraphFont semiHidden
- Ours: NO `<w:semiHidden/>` element
- Repaired: HAS `<w:semiHidden/>` element
- **Root cause found**: lutaml-model `element_order` from template parsing doesn't include `semiHidden`. Setting the attribute in-place doesn't update element_order, so serialization skips it.
- **Fix**: Rebuild the DefaultParagraphFont style object entirely in `ensure_default_styles` so it gets a fresh element_order. Fixed in `uniword/lib/uniword/docx/reconciler/parts.rb`.
- **Impact**: LOW for "unreadable content" (missing semiHidden is cosmetic), but should match Word's expected output.

### B5. document.xml — `<w:b/>` elements
- Ours: 5 `<w:b/>` (bold, no val attribute) elements in runs
- Repaired: 0 (Word removes redundant bold markers)
- **Impact**: None. `<w:b/>` without val defaults to true. Valid OOXML.

---

## Category C: Metadata / Low-Significance Differences

### C1. settings.xml — Zoom attribute
- Ours: `<w:zoom w:val="bestFit" w:percent="160"/>`
- Repaired: `<w:zoom w:percent="104"/>` (no `w:val` attribute)
- Word recalculates zoom during save. `bestFit` is valid but Word replaces it.
- **Impact**: LOW. Zoom is a UI hint, not structural.

### C2. fontTable.xml — SimSun sig usb0
- Ours: `w:usb0="00000003"`
- Repaired: `w:usb0="00000203"`
- Font signature metadata. Word may update font signatures based on installed fonts.
- **Impact**: LOW. Not structural.

### C3. app.xml — HeadingPairs / TitlesOfParts
- Ours: HAS `<HeadingPairs>` and `<TitlesOfParts>` with vt:vector elements
- Repaired: Does NOT have these elements
- **Impact**: LOW. Document metadata, Word may strip during save.

---

## Category D: No Differences (verified identical after normalization)

- **docProps/core.xml**: IDENTICAL
- **word/theme/theme1.xml**: IDENTICAL
- **footnotes/endnotes/headers/footers**: Only namespace ordering (Category A1)
- **webSettings.xml**: Same 71 div elements with same IDs, only namespace ordering difference
- **Bookmark IDs**: 104 starts = 104 ends, all matched, no duplicates
- **Footnote/endnote IDs**: No duplicates, proper separator/continuationSeparator types

---

## Conclusion

After exhaustive analysis of every XML part, every element, every attribute, every ID:

1. **No structural errors found** that would explain "unreadable content"
2. **All differences are cosmetic or content-level** changes that Word makes during save
3. **The mc:Ignorable fix is correctly applied** (all prefixes match repaired output)
4. **The DefaultParagraphFont semiHidden fix is not being applied** — needs investigation

### Remaining hypotheses for "unreadable content":

1. **Something in the XML serialization** not visible in text comparison (e.g., encoding nuance, XML declaration difference, whitespace in element content)
2. **A Word validation rule not covered by structural checks** (e.g., element ordering within a complex type, required but empty elements, attribute value validation beyond what we've checked)
3. **The template DOCX itself has issues** that propagate through our processing pipeline but are fixed by Word's repair

### Action items:
- [x] Investigate why DefaultParagraphFont semiHidden fix wasn't being applied → Fixed (element_order issue)
- [x] Fix: rebuild style object instead of modifying in-place → Fixed in parts.rb
- [ ] Test rice_fixed16.docx in Word to see if it opens without "unreadable content"
- [ ] If still failing, try generating DOCX WITHOUT template (from scratch) to isolate template issues
- [ ] If still failing, try replacing individual XML parts from repaired into ours to isolate which part triggers the error
