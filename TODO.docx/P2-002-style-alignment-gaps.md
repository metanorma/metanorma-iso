---
title: 108-007 - Align paragraph styles with reference
priority: P2
status: done
---

# 108-007: Align Paragraph Styles with Reference

## Closed (2026-11-20): measured against the submitted 5878 WD DOCX

The private 5878 WD source was converted with the default DIS template and
compared per `w:pStyle` with the submitted `.docx` (private content stays
outside the repository). Conversion: about 107 s, 1.1-1.35 GB peak RSS.

- Outside tables, every style delta is template-bound, the same pattern as
  rice: ListParagraph/BiblioEntry, TOC1 depth, Tabletitle/AnnexTableTitle,
  ListContinue1/ListNumber1, Formula, FigureGraphic, Figuretitle/FigureTitle.
  `zzCover`, `CoverTitleA1`, `Formula` and `Notice` are DIS template styles;
  the DIS mapping sends the cover warning to `Notice` by design (the Simple
  mapping uses zzwarninghdr/zzwarning). `PAGEBREAK` shows no delta.
- One real defect came out of it: table `rowspan` produced no vertical-merge
  continuation cells, so cells in covered rows shifted left. Fixed in the
  same change (`table_row_spans.rb`). Table cells after the fix: 27,416 vs
  27,419 in the submission (26,966 before).
- The last gap was table footnotes. In the submission they are a
  superscript letter in the cell, with the bodies in one final full-width
  row in Note style and no Word footnote reference in any table. The output
  now does the same (`table_footnotes.rb`): 2,085 table rows in both, 0
  footnote references inside tables in both (38 before), and no table
  differs from the submission in row count or Note paragraphs (37 tables).

Simple bibliography entries now use `ListParagraph`, covered by
`bibliography_renderer_spec.rb`. DIS retains `BiblioEntry`, `Warningtext`,
`Warningtitle`, `Figuretitle`, and `Tabletitle` because its template lacks
the older reference styles. Simple already defines and maps its annex
caption styles. Note and example counts remain tracked in P2-010.

Parity now treats `Tablebody`/`Tableheader` paragraphs inside table cells
as equivalent to unstyled/Normal cell paragraphs. Literal heading numbers
and style-supplied numbering already produce the same structure/style
tokens. Both equivalences are covered by `spec/isodoc/docx/mhtml_parity_spec.rb`,
which also preserves heading-level differences and other cell styles.
The style/count items below were left open at this stage; the 2026-11-20
measurement above closes them.

Measured against submitted `iso-wd-5878-2024.doc` (20241129 submission):
the 26,977 `Tablebody` paragraphs in `/tmp/5878.docx` no longer produce
style-only deltas. The report has 466 remaining deltas and completed in
29.6 seconds. A fresh Processor DOCX conversion of the same submission
has 467 remaining deltas (55.7 seconds). Private source content remains
outside the repository.

## Remaining list (2026-11-19 re-check)

The private `/tmp/5878.docx` and the delta tool are not on this machine, so
no bucket was re-measured against the submission. Checked from the repository
instead (rice fixture `spec/fixtures/iso/is/document-en.presentation.xml`,
default DIS template, per-style `w:pStyle` counts):

- Items 1 and 4 (ListParagraph, AnnexFigureTitle/AnnexTableTitle) are done in
  the Simple mapping. Items 2 and 3 (zzwarning/zzwarninghdr) cannot be done:
  neither template defines those styles (DIS keeps Warningtext/Warningtitle).
- Items 6 and 7 (note/example counts) are closed by P2-010.
- Item 8 (`a3` over-use): the 18 `a3` paragraphs in the rice fixture are
  level-3 annex clause titles (for example "Sample divider,", "Preparation of
  test sample"), which is the intended `annex_heading3` mapping. `a3` is not a
  fallback style; no code change. A different count in the submission needs
  the submission to diagnose.
- Still open, needs the private source: which of the 466 deltas remain, and
  `zzCover`, `CoverTitleA1`, `Formula`, `PAGEBREAK` differences.

## Rice measurement (2026-11-19, lane/1728-pstyles @ 2e463195)

Processor DOCX of `spec/examples/rice.presentation.xml` against the reference
`spec/examples/rice.docx` (2016 CD), per-style `w:pStyle` counts. Output has
434 styled paragraphs of 514; the reference 207 of 515 (it leaves most body
paragraphs unstyled). No code change came out of it: every delta is
template-bound or edition-bound.

| Style (out vs ref) | Verdict |
|---|---|
| Tablebody 132/0, Tableheader 12/0 | Template styles; parity already treats as Normal (item 5). |
| a3 18/1 | Edition: source has 18 level-3 annex titles (item 8). |
| BiblioEntry 15 / ListParagraph 0 vs 14 | DIS template has no ListParagraph (Simple maps it). |
| ListContinue1 12, ListNumber1 9 vs 0 | Ref leaves list paragraphs unstyled; DIS defines both. |
| zzCover 10, CoverTitleA1/2, MainTitle1/2 | Cover/title layout differs in the 2016 reference. |
| Note 5 + Noteindent 6 vs Note 15 | Source has 9 notes + 5 termnotes; P2-010 matches each one. |
| TermsAdmitted 8 vs AltTerms 6 | DIS template has no AltTerms/DeprecatedTerms. |
| RefNorm 7 vs normref 7 | DIS template has no normref. |
| Figuretitle 6 vs AnnexFigureTitle 6 | DIS template has no AnnexFigureTitle. |
| Warningtext/title 2/2 vs zzwarning/hdr 2/1 | DIS template has none (Notice). |
| Formula, KeyTitle/Text, FigureGraphic, Box-*, Formuladescription | Defined by the DIS template; ref leaves them unstyled. |
| Code 2 vs 1 | Extra is the code-callout annotation, absent in the 2016 source. |
| Definition 17 vs 16 | Extra is the "N/A" definition-list entry. |

Closing these needs template styles (out of scope: mapping-only rule) or the
private submission. Superseded by the 2026-11-20 measurement above: these
deltas are template-bound, not defects.

## Problem

Many style assignments differ between latest output and reference:

### Styles used in latest but NOT in reference:
| Style | Count in Latest | Notes |
|-------|----------------|-------|
| Tablebody | 121 | Reference doesn't use explicit table body style |
| Tableheader | 12 | Reference doesn't use explicit table header style |
| BiblioEntry | 17 | Reference uses ListParagraph (14) for bib entries |
| Warningtext | 4 | Reference uses zzwarning (2) |
| Warningtitle | 1 | Reference uses zzwarninghdr (1) |
| Figuretitle | 3 | Reference uses AnnexFigureTitle (6) for annex figs |
| zzCover | 8 | Cover page paragraphs |
| CoverTitleA1 | 1 | Cover title |
| Formula | 4 | Formula paragraphs |
| PAGEBREAK | 2 | SectPr paragraphs |

### Styles used in reference but NOT in latest:
| Style | Count in Ref | Notes |
|-------|-------------|-------|
| ListParagraph | 14 | Used for bibliography entries |
| AnnexFigureTitle | 6 | Used for annex figure titles |
| AnnexTableTitle | 1 | Annex table title |

### Style count mismatches:
| Style | Latest | Ref | Issue |
|-------|--------|-----|-------|
| Note | 6 | 15 | Many notes have wrong style or missing |
| a3 | 23 | 1 | a3 over-used in latest |
| Example | 2 | 4 | Missing example name paragraphs |
| Definition | 15 | 16 | Missing one definition |

## Fix Plan

1. **BiblioEntry → ListParagraph**: Change bib item style mapping for non-normative bibliography
2. **Warningtext → zzwarning**: Update style mapping for warning paragraphs
3. **Warningtitle → zzwarninghdr**: Update style mapping for warning title
4. **Figuretitle → AnnexFigureTitle**: When in annex context, use AnnexFigureTitle
5. **Tablebody/Tableheader**: Done — keep template styles; normalize equivalent cell paragraphs in MhtmlParity.
6. **Note count**: Investigate why only 6 notes vs 15
7. **Example count**: Investigate why only 2 vs 4
8. **a3 over-use**: Check if a3 is being used as fallback style

## Files to Change

- `data/iso-dis/style_mapping.yml` — update style mappings
- `lib/isodoc/iso/docx/style_resolver.rb` — context-aware style dispatch
- `lib/isodoc/iso/docx/adapter.rb` — fix style selection in visitors
