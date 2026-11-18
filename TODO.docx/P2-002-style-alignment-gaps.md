---
title: 108-007 - Align paragraph styles with reference
priority: P2
status: partial
---

# 108-007: Align Paragraph Styles with Reference

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
Status remains partial: the other style/count items below are outside this
parity change.

Measured against submitted `iso-wd-5878-2024.doc` (20241129 submission):
the 26,977 `Tablebody` paragraphs in `/tmp/5878.docx` no longer produce
style-only deltas. The report has 466 remaining deltas and completed in
29.6 seconds. A fresh Processor DOCX conversion of the same submission
has 467 remaining deltas (55.7 seconds). Private source content remains
outside the repository.

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
