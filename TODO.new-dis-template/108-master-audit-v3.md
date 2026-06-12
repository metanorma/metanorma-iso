---
title: 108 - Master Audit v3 — Full DOCX Diff Analysis
created: 2026-06-11
status: active
---

# 108: Master Audit v3 — Full DOCX Diff Analysis

## Generated: `data/rice-dis-output-latest.docx` (530KB, Jun 11 16:32)
## Reference: `spec/examples/rice.docx` (924KB, May 17)

---

## Current Stats

| Metric | Reference | Latest | Delta | Status |
|--------|-----------|--------|-------|--------|
| Body elements | 374 | 311 | -63 | GAP |
| Body paragraphs | 349 | 304 | -45 | GAP |
| Tables | 6 | 6 | 0 | ✅ |
| Section breaks | 3 | 3 | 0 | ✅ |
| Page breaks | 9 | 6 | -3 | GAP |
| Bookmarks (total) | 293 | 206 | -87 | GAP |
| Bookmarks (top-level) | 18 | 0 | -18 | GAP |
| Hyperlinks | 120 | 75 | -45 | GAP |
| rStyles | ~810 | 186 | -624 | GAP |
| TOC entries | 26 | 0 | -26 | GAP |
| Images | 5 | 4 | -1 | GAP |
| Comments | yes | no | missing | GAP |
| File opens in Word | ✅ | ❓ | unknown | CRITICAL |

## CRITICAL Issue: File May Not Open

The previous audit (107) claimed the file should open after fixing dc:title and missing styles. The user reports it "no longer opens." Possible causes:

1. **Cover page sectPr has no header/footer references** — Reference has rId7 (header), rId8/rId9 (footers). Latest has none. Word may choke.
2. **Template changed** — template.docx went from 45KB → 195KB. Cover page structure may have changed.
3. **Cover page copyright block is on the wrong page** — Before sectPr instead of after.

## Structural Differences

### 1. Cover Page Section Break (CRITICAL)

**Reference flow:**
- Index 0-11: Cover page content (doc number, title, warning, etc.)
- Index 12: Space paragraph ` `
- Index 13: **SECTPR** (cover page section end) with header rId7 + footers rId8/rId9
- Index 14: "© ISO 2016" (starts NEW page — copyright page)
- Index 15-17: Copyright text + address + "Published in Switzerland"
- Index 18: **PAGE BREAK** (before TOC)

**Latest flow:**
- Index 0-11: Cover page content (same)
- Index 12: "© ISO 2016" (still on cover page!)
- Index 13-15: Copyright text + address + "Published in Switzerland"
- Index 16: **SECTPR** (after copyright — cover includes copyright)
- Index 17: "Contents" (NO page break before TOC)

**Problem:** Copyright block is on the cover page, not on its own page. Missing page break before Contents.

### 2. Missing TOC Entries (HIGH)

Reference has 26 TOC entries:
- 18× TOC1 (main sections: Foreword, Scope, Normative refs, etc.)
- 7× TOC2 (subsections)
- 2× TOC3 (sub-subsections)

Latest has only 1× TOC1 (the "Contents" heading). No actual TOC entries.

### 3. Missing Page Breaks (HIGH)

Reference has 9 page breaks, latest has 6. Missing:
| Location | Reference Index | Latest Equivalent | Status |
|----------|----------------|-------------------|--------|
| Before Contents | 18 | ❌ missing | GAP |
| Before Foreword | 47 | ❌ missing | GAP |
| Before Introduction | 60 | ❌ missing | GAP |
| Before Annex A | 222 | 185 | ✅ |
| Before Annex B | 260 | 220 | ✅ |
| Before Annex C | 309 | 266 | ✅ |
| Before Annex D | 337 | 275 | ✅ |
| Before Annex E | 343 | 281 | ✅ |
| Before Bibliography | 354 | 291 | ✅ |

### 4. First sectPr Missing Headers/Footers (HIGH)

| Property | Reference | Latest |
|----------|-----------|--------|
| headerReference even | rId7 | ❌ none |
| footerReference even | rId8 | ❌ none |
| footerReference default | rId9 | ❌ none |
| w:cols | space=720 | ❌ missing |
| w:docGrid | linePitch=360 | ❌ missing |

## Style Differences

| Style | Latest Count | Ref Count | Issue |
|-------|-------------|-----------|-------|
| Tablebody | 121 | 0 | Ref doesn't use explicit table body style |
| Tableheader | 12 | 0 | Ref doesn't use explicit table header style |
| BiblioEntry | 17 | 0 | Ref uses ListParagraph for bib entries |
| Warningtext | 4 | 0 | Ref uses zzwarning |
| Warningtitle | 1 | 0 | Ref uses zzwarninghdr |
| Figuretitle | 3 | 0 | Ref uses AnnexFigureTitle for annex figs |
| zzCover | 8 | 0 | Cover uses different style approach |
| CoverTitleA1 | 1 | 0 | Cover title style |
| Formula | 4 | 0 | Formula rendering |
| PAGEBREAK | 2 | 0 | SectPr paragraphs style |
| ListParagraph | 0 | 14 | Missing from latest |
| Note | 6 | 15 | Count mismatch |
| a3 | 23 | 1 | Over-used in latest |

## Content Differences

1. **Missing comments** — Reference has comments.xml + extended. Latest has none.
2. **Missing image** — Reference has 5 images, latest has 4.
3. **Normref footnote markers** — Some ref entries have extra `)` after ISO reference.
4. **Annex subheadings** — Format differs (numbering + text separation).
5. **Formula rendering** — Plain text in latest vs MathML in reference.
6. **Sourcecode formatting** — Newlines not preserved.
7. **Duplicate terms boilerplate** — Latest renders both old and new boilerplate text.

## Section Properties Comparison

### sectPr[0] (Cover page end)
| Property | Reference | Latest |
|----------|-----------|--------|
| Position | Index 13 (before copyright) | Index 16 (after copyright) |
| Header even | rId7 (header1.xml) | ❌ none |
| Footer even | rId8 (footer1.xml) | ❌ none |
| Footer default | rId9 (footer2.xml) | ❌ none |
| pgSz | 11906×16838 | 11906×16838 ✅ |
| pgMar | same | same ✅ |
| w:cols | space=720 | ❌ missing |
| w:docGrid | linePitch=360 | ❌ missing |

### sectPr[1] (Front matter end)
| Property | Reference | Latest |
|----------|-----------|--------|
| Position | Index 71 | Index 40 |
| Header even | rId16 | rId16 ✅ |
| Header default | rId17 | rId17 ✅ |
| Footer even | rId18 | rId18 ✅ |
| Footer default | rId19 | rId19 ✅ |
| pgNumType | fmt=lowerRoman | fmt=lowerRoman ✅ |

### sectPr[2] (Body)
| Property | Reference | Latest |
|----------|-----------|--------|
| Footer even | rId35 | rId27 |
| Footer default | rId36 | rId28 |
| pgNumType | start=1 | start=1 ✅ |
| w:cols | space=720 | space=720 ✅ |

## Missing OOXML Parts

| Part | Reference | Latest | Status |
|------|-----------|--------|--------|
| comments.xml | ✅ | ❌ | Missing |
| commentsExtended.xml | ✅ | ❌ | Missing |
| commentsIds.xml | ✅ | ❌ | Missing |
| commentsExtensible.xml | ✅ | ❌ | Missing |
| header1.xml | ✅ | ✅ | OK |
| footer5.xml | ✅ | ❌ | Different parts |
| footer6.xml | ✅ | ❌ | Different parts |
| custom.xml | ❌ | ✅ | Extra (not in ref) |

## Prioritized Fix Plan

### P0 — File must open
- [ ] 108-001: Fix cover page sectPr position and header/footer refs
- [ ] 108-002: Verify file opens after cover page fix

### P1 — Visual correctness
- [ ] 108-003: Add page breaks before Contents, Foreword, Introduction
- [ ] 108-004: Move copyright block to separate page
- [ ] 108-005: Add TOC entries (or Word field instruction)
- [ ] 108-006: Fix missing image (5th image for Annex C subfigures)

### P2 — Style alignment
- [ ] 108-007: Use ListParagraph for bibliography entries
- [ ] 108-008: Use zzwarning/zzwarninghdr for warnings
- [ ] 108-009: Use AnnexFigureTitle for annex figure titles
- [ ] 108-010: Add missing rStyles (runs formatting)
- [ ] 108-011: Remove PAGEBREAK style from sectPr paragraphs

### P3 — Content accuracy
- [ ] 108-012: Add comments support
- [ ] 108-013: Fix formula rendering (MathML→OMML)
- [ ] 108-014: Fix sourcecode formatting
- [ ] 108-015: Deduplicate terms boilerplate text
- [ ] 108-016: Add missing bookmarks/hyperlinks
