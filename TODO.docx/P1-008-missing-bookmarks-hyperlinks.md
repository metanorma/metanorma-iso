# 070: Fix Missing Bookmarks and Hyperlinks

status: done (remainder classified as non-defects, see Status update)

## Status (measured on rice, base 7774b78e)
- Before: 125 bookmarks, 76 hyperlinks. After: 195 bookmarks (all unique), 85 hyperlinks. Reference: 293 / 120.
- Figures, tables, formulas, headings, terms and bib items already had bookmarks; the premise that figures/tables lacked them was false.
- Fixed: paragraphs with an id now get a bookmark (+70); fmt-concept now renders its xref as a hyperlink (+9, also restores the "(3.1)" display text).
- Remaining delta: ~26 _Toc hyperlinks (toc_builder lane); ~98 bookmarks the reference carries on notes, lists, dl, termnote/termexample, quote, sourcecode and some clauses (Word-authored GUID bookmarks, no xref targets them); term anchors differ (ref `paddy`, source `term-paddy`); 11 table-footnote hyperlinks.

- Classification (lane 1728-xref-links, measured at e6c302ba): every source xref/fmt-xref/eref target (77 fmt-xref) yields exactly one internal hyperlink; all anchors resolve to bookmarks; no emitted-link defect remains. Locked by spec/isodoc/docx/rice_xref_links_spec.rb.
- Reference-only links are edition differences (reference = 2016 CD, source = 2023 DIS): table1a..d (7x table1c), tableD-1a, figureC-1a are Word-authored bookmarks on in-table footnote text; the source has no such targets (table fn are `fn` + fmt-footnote-container, rendered by us as native Word footnotes with bodies in footnotes.xml). IEC61010-2, AnnexA(+1), figureA-1(+1) have no/fewer xrefs in the source (IEC61010-2: 0; AnnexA: 2 fmt-xref vs 3 in ref; figureA-1: 1 vs 2). Term anchors differ by naming (ref `paddy`, ours `term-paddy`).
- Remaining delta: _Toc hyperlinks (toc_builder lane) only; the rest is not a defect.

## Status update (lane 1728-bookmarks2, base 2e463195) - status: done, remainder documented as non-defects
Measured on rice (Metanorma::Iso::Processor output, docx) vs reference spec/examples/rice.docx (2016 CD):

| Kind | Reference | Before (2e463195) | After |
|---|---|---|---|
| Bookmarks, total | 293 | 231 | 368 (all unique, longest name 37 chars, limit 40) |
| - semantic ids (clause/term/figure/table/boilerplate names) | 82 | 79 | 85 |
| - GUID-style ids (`_xxxxxxxx-...`, one per block/paragraph) | 201 | 126 | 257 |
| - _Toc (heading, for the TOC) | 0 (ref TOC links dangle) | 26 | 26 |
| - _Ref (Word cross-ref helpers) | 10 | 0 | 0 (documented, no source) |
| Hyperlinks, total | 120 | 111 | 111 |
| - internal anchor | 113 | 103 | 103 (26 _Toc + 77 xref) |
| - external | 7 | 8 | 8 |
| Dangling hyperlink anchors | 32 (26 _Toc + 6 table/figure fn) | 0 | 0 |

Real gap fixed (+137 bookmarks; 368 now exceeds the reference because we anchor every id-bearing block, which the 2016 CD did not): ids on note, termnote, termexample, example, admonition, quote, sourcecode, ul/ol, li, the p inside li/dd/termnote/definition/boilerplate, dl/dt/dd, fmt-definition, figure notes, and the boilerplate statement clauses/paragraphs now become bookmarks (anchor on the first paragraph the block emits). Names are claimed once (Context#claim_bookmark_name), so duplicates and names over 40 chars are never emitted. Locked by spec/isodoc/docx/anchored_block_bookmarks_spec.rb.

Not defects (classified, not fixed):
- Reference is above ours on 5 bookmark kinds that no source element carries: 10 _Ref* (Word-generated cross-reference helpers on normref/bibliography/term text), ftntable1a..d/ftnfigureC-1a/ftntableD-1a (Word-authored in-table footnote text of the 2016 CD; ours are native Word footnotes). Edition differences / Word-generated.
- Term anchors: reference `paddy`, `husked_rice`, `HDK`, `gelatinization`, `gel_state`; ours `term-paddy` etc. (naming, xrefs resolve either way).
- Hyperlinks: reference-only links are table1a..d, tableD-1a, figureC-1a (table footnotes of the 2016 CD) and IEC61010-2 (no xref in the 2023 source), and the 26 reference _Toc links point at bookmarks that do not exist in the reference; ours point at real _Toc bookmarks. Every source xref/eref yields one hyperlink (rice_xref_links_spec).
- Source elements deliberately not bookmarked: annotation/fmt-annotation-* and the ul/li inside annotation-container (rendered as Word comments); the 5 `<bookmark>` elements in annex titles and refterm are review-annotation range ends (from/to of annotations), carried by the comment ranges; link/xref/eref/stem/identifier/title/fmt-name/td/tr/th inline or structural nodes that are not anchor targets.
- Not done: dl ids in figure-key/formula-key/symbol tables (2 of 4 dl; the dl renders as table cells with no body paragraph to hold the range); p ids inside table-cell fn bodies and footnotes.xml; modification/source p (3).

## Problem
The reference has 293 bookmarks and 120 hyperlinks. The output has only 98 bookmarks and 75 hyperlinks. Missing bookmarks mean cross-references and internal links may be broken.

## Evidence
```
Reference: 293 bookmarks, 120 hyperlinks
Output:     98 bookmarks,  75 hyperlinks
Delta:     -195 bookmarks, -45 hyperlinks
```

The missing bookmarks are likely related to:
1. Missing annex headings (no bookmark targets for Annex A-E)
2. Missing TOC entries (no hyperlink targets)
3. Missing figure/table cross-reference targets

## Fix
1. Ensure every heading generates a bookmark anchor
2. Ensure annex headings get bookmarks
3. Ensure figure/table titles get bookmarks
4. Ensure cross-references (`<xref>`) generate hyperlinks to bookmark targets

## Priority
**MEDIUM** — Internal navigation is degraded but document still opens.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — bookmark generation
- `lib/isodoc/iso/docx/inline.rb` — hyperlink rendering
