# 070: Fix Missing Bookmarks and Hyperlinks

status: partial

## Status (measured on rice, base 7774b78e)
- Before: 125 bookmarks, 76 hyperlinks. After: 195 bookmarks (all unique), 85 hyperlinks. Reference: 293 / 120.
- Figures, tables, formulas, headings, terms and bib items already had bookmarks; the premise that figures/tables lacked them was false.
- Fixed: paragraphs with an id now get a bookmark (+70); fmt-concept now renders its xref as a hyperlink (+9, also restores the "(3.1)" display text).
- Remaining delta: ~26 _Toc hyperlinks (toc_builder lane); ~98 bookmarks the reference carries on notes, lists, dl, termnote/termexample, quote, sourcecode and some clauses (Word-authored GUID bookmarks, no xref targets them); term anchors differ (ref `paddy`, source `term-paddy`); 11 table-footnote hyperlinks.

- Classification (lane 1728-xref-links, measured at e6c302ba): every source xref/fmt-xref/eref target (77 fmt-xref) yields exactly one internal hyperlink; all anchors resolve to bookmarks; no emitted-link defect remains. Locked by spec/isodoc/docx/rice_xref_links_spec.rb.
- Reference-only links are edition differences (reference = 2016 CD, source = 2023 DIS): table1a..d (7x table1c), tableD-1a, figureC-1a are Word-authored bookmarks on in-table footnote text; the source has no such targets (table fn are `fn` + fmt-footnote-container, rendered by us as native Word footnotes with bodies in footnotes.xml). IEC61010-2, AnnexA(+1), figureA-1(+1) have no/fewer xrefs in the source (IEC61010-2: 0; AnnexA: 2 fmt-xref vs 3 in ref; figureA-1: 1 vs 2). Term anchors differ by naming (ref `paddy`, ours `term-paddy`).
- Remaining delta: _Toc hyperlinks (toc_builder lane) only; the rest is not a defect.

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
