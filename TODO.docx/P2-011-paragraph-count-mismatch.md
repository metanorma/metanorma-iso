---
title: P2-011 - Paragraph count mismatch
priority: P2
status: partial
---

# P2-011: Paragraph count mismatch

## Re-measurement on base 6455ca2f (2026-11-19, batches 3-4)

Same method (rice.presentation.xml through `Processor#output(..., :docx)`,
reference `spec/examples/rice.docx`, body children plus `w:tc` paragraphs).

| | 7774b78e output | 6455ca2f output | reference | delta now |
|---|---|---|---|---|
| body paragraphs | 353 | 365 | 349 | +16 |
| table-cell paragraphs | 150 | 150 | 166 | -16 |
| total | 503 | 515 | 515 | 0 |

The totals now match, but by cancellation, not by correctness: the body
excess (+16) and the table deficit (-16) are the same structural choices
listed below. Batches 3-4 added 12 body paragraphs since 7774b78e; the
diff of the paragraph sequences (text, 243 differing paragraphs each way)
shows they are the items already classified, not new defects:

- Annex C figure key and legend: output emits KeyTitle/KeyText body
  paragraphs, the reference puts them in a table (about +10 body, -10 table);
  the reference table-cell paragraphs also hold the Annex E callout key
  (3) and the Table 2/3 footnote bodies (`aOrganic ...`, `b`, `c`, `d`,
  `aParboiled rice.`; text is in `footnotes.xml` in the output, -5).
- Admonition wrappers (Box-begin, Warningtitle, Warningtext, Box-end) +6 vs
  one reference paragraph.
- Edition content (CD 2016 vs DIS 2023): reference-only patent notice (6
  paragraphs), cover warning block (4), third IEC Electropedia link block,
  two more bibliography entries; output-only 5 list items, DIS cover
  metadata lines, bilingual title (P2-007), the extra `brown rice`
  admitted-term paragraph and the Foreword feedback paragraph.
- Empty body paragraphs: output 28, reference 19 (Box-begin/Box-end,
  formula spacers, KeyTitle for stem-only terms), unchanged judgement.

Verdict: no bounded renderer bug found in an unowned area, so no code was
changed. The belief "remaining gap is edition difference plus known design
choices" holds for the paragraph count; the count is not an oracle. The
remaining actionable items stay with their cards: P1-003 (figure key and
sub-figures), P2-007 (cover/title), P1-005 (copyright address), P2-010
(example label), and the BUG 020 judgement item below.

## Re-measurement on base 7774b78e (2026-11-19)

Source `spec/examples/rice.presentation.xml` converted with
`Metanorma::Iso::Processor#output(..., :docx)`; reference is the committed
`spec/examples/rice.docx`. Paragraphs counted structurally (body children,
table cell paragraphs counted once, nested tables not double counted).

| | output | reference | delta |
|---|---|---|---|
| body paragraphs | 353 | 349 | +4 |
| table-cell paragraphs | 150 | 166 | -16 |
| total | 503 | 515 | -12 |

The card's "291 vs 349" is stale: the body count is now above the
reference. The remaining total gap is 12, not 58.

Caveat: `rice.docx` is a Word-authored ISO/CD 17301-1 (2016, second edition);
the presentation XML is ISO/DIS 17301-1:2023 (third edition). Text and
structure differ by edition, so a paragraph diff cannot be driven to zero
and is not a renderer-correctness oracle.

Per section, body (output - reference): cover +2, TOC -1, foreword +1,
introduction -3, terms -3, specs -2, clauses 6-9 +9, Annex A -1, B -4,
C +11, D -1, E -2, bibliography -2 (sum +4).

## Classified differences (output minus reference)

| Cause | Count | Example | Owner / verdict |
|---|---|---|---|
| Edition content differs (CD 2016 vs DIS 2023) | about -4 net | patent notice paragraphs in the reference introduction; 5 list items "method; test material; ..." only in output; 2 more references in reference bibliography | not a bug |
| Cover and middle title (bilingual DIS title) | +4 | `Reference number of working document: 17301`; MainTitle1/2 twice | P2-007, not touched |
| Copyright address emitted twice (`zzCopyright` plus `zzCopyrightaddress`) | +1 | `ISO copyright office CP 401 ...` | P1-005 / boilerplate, not touched |
| Word-native footnotes instead of footnote paragraphs below table and figure | -6 | `aOrganic extraneous matter includes foreign seeds...` (text is present in footnotes.xml) | design, kept |
| Number-only inline-header sub-clauses dropped by design (BUG 020) | -7 | `4.2.1`, `4.2.2`, `B.5.1` to `B.5.5` | judgement, see below |
| Annex `variant-title-toc` hidden paragraphs absent | -5 | `Annex CGelatinization` | toc_builder lane |
| Admonition box wrappers (Box-begin, Warningtitle, Warningtext, Box-end) vs one paragraph | +6 | `WARNING - Only use paddy or parboiled rice...` | style choice |
| Example label and body as two paragraphs | +2 | `EXAMPLE` / `Foreign seeds, husks, bran, sand, dust.` | P2-010 territory |
| Figure key as KeyTitle/KeyText paragraphs; reference uses a table | +10 body, -10 table, net 0 | Figure C.1 key | P1-003 / figure lane |
| Sub-figures a), b), c) as Figuretitle paragraphs | part of Annex C +11 | `a) Initial stages ...` | P1-003, not touched |
| Code callout paragraph vs callout table | about +1 | `This is an annotation` | style choice |
| Empty body paragraphs | output 28, reference 21 | | see below |

Rows are measured from a sequence diff of paragraph text and styles; the
per-row counts are approximate where text differs by edition. Only the
three totals and the per-section sum are exact.

## Word-specific spacer paragraphs

The reference has 19 unstyled blank paragraphs (Word page and section
spacing); the output has 10 plus 18 styled empties (Box-begin/Box-end,
KeyTitle for stem-only terms, Formula). Do not reproduce the spacers: the
output uses page-break and spacing properties, and adding blanks would
raise the count without changing the layout.

## Fix status

No simple renderer bug in an unowned file was found. Rendered text
losses seen while diffing (`paddy (3.1)` cross-reference text) are inline
xref issues, not paragraph-count causes, and belong to the hyperlink lane.
The ± in `100 mm ± 5 mm` is NOT lost: it is a lone-operator inline stem
rendered as `<m:oMath><m:r><m:t>±</m:t></m:r></m:oMath>` between the `w:t`
runs (measured on rice DOCX, pinned in stem_renderer_spec.rb). A `w:t`-only
text extractor does not see it.

Open judgement item: BUG 020 skips the heading paragraph of untitled
inline-header sub-clauses, which also drops the clause number (4.2.1 and
similar) from the document. A fix would prefix the number as a run on the
first body paragraph (as the ISO HTML does), not emit a heading. It
touches `inline.rb` and `section_renderer.rb`, and is guarded by
`adapter_spec.rb` BUG 020 and `toc_entries_spec.rb`, so it needs a
decision rather than a drive-by change.
