# 073: Master Audit Update — DOCX Output vs Reference (rice.docx)

Comprehensive comparison of `data/rice-dis-output-latest.docx` vs `spec/examples/rice.docx`.

## Current Stats

| Metric | Reference | Output | Delta |
|--------|-----------|--------|-------|
| Body paragraphs | 349 | 307 | **-42** |
| Tables | 6 | 6 | 0 ✓ |
| Bookmarks | 293 | 103 | **-190** |
| Hyperlinks | 120 | 75 | **-45** |
| Footnote refs | 10 | 22 | +12 |
| rStyles | 810 | 186 | **-624** |
| pStyles | 207 | 343 | +136 |
| Unique footnotes | 12 | 10 | -2 |

## Previously Fixed (058-072)

| # | Issue | Status |
|---|-------|--------|
| 058 | Cover sectPr header/footer refs | ✓ Fixed |
| 059 | Missing annex headings (A-E) | ✓ Fixed |
| 064 | Section breaks for annexes/biblio | ✓ Fixed |
| 063 | Pervasive whitespace | ✓ Partially fixed |
| 067 | rStyle assignments | ✓ Partial (12 semantic rStyles added) |
| 066 | Body sectPr differences | ✓ Fixed |
| 062 | Footnote deduplication | ✓ Fixed (16→10) |
| 065 | Missing normref preamble | ✓ Fixed |
| 068 | Missing tables | ✓ Fixed (3→6) |

## Remaining Issues (Priority Order)

### CRITICAL (affects document usability)

| # | Issue | Paragraphs | Priority |
|---|-------|-----------|----------|
| 074 | Cover page structure wrong | ~8 paras | P1 |
| 073 | TOC entries missing | 26 paras | P1 |
| 076 | Middle title page | 1 para | P1 |
| 079 | Formula rendering (plain text, no MathML) | ~8 paras | P1 |

### HIGH (affects content accuracy)

| # | Issue | Paragraphs | Priority |
|---|-------|-----------|----------|
| 078 | Normref footnote `)` markers | ~8 refs | P2 |
| 085 | Duplicated terms preamble | 4 paras | P2 |
| 081 | Missing sub-figure descriptions | 3 paras | P2 |
| 082 | Sourcecode formatting | 2 paras | P2 |
| 087 | "ISO" prefix merged into text | multiple | P2 |

### MEDIUM (cosmetic/structural)

| # | Issue | Paragraphs | Priority |
|---|-------|-----------|----------|
| 075 | Copyright address consolidation | 4 paras | P3 |
| 080 | Annex heading format (bold/spacing) | 5 paras | P3 |
| 083 | Bibliography formatting | multiple | P3 |
| 086 | Note formatting (extra spaces) | multiple | P3 |
| 084 | Inline page breaks (verify) | 0 paras | P3 |

### LOW (future improvements)

| # | Issue | Priority |
|---|-------|----------|
| 070 | Missing bookmarks (-190) | P4 |
| 070 | Missing hyperlinks (-45) | P4 |
| 067 | Missing rStyles (stem, FootnoteReference) | P4 |
| 072 | Missing comments | P5 |
| 077 | Section numbers in headings | Closed — not an issue |

## Paragraph Deficit Breakdown (-42)

- TOC entries: -26
- Cover page differences: -8
- Middle title: -1
- Sub-figure descriptions: -3
- Sourcecode/patent block: -2
- Duplicated preamble (output has extras): +4
- Other content differences: -6
