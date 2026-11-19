# 089: Missing 190 bookmarks and 45 hyperlinks

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
Output has 103 bookmarks vs reference 293 (-190). Output has 75 hyperlinks vs reference 120 (-45).

## Analysis
The reference places bookmarks on:
- Every heading (clause, annex, bibliography titles)
- Every term (3.1 through 3.15)
- Every figure and table
- Every bibliography entry
- Various other elements

The reference places hyperlinks on:
- Every cross-reference (xref/eref)
- External URLs
- TOC entries

The output creates bookmarks via `insert_bookmark` for headings, terms, and bib items, but is missing many elements. Cross-references from `render_xref` and `render_fmt_xref` create hyperlinks but many xrefs may not be rendered.

## Fix
1. Ensure all headings get a bookmark (already partially done)
2. Ensure all figures and tables get a bookmark
3. Ensure all xref elements generate proper hyperlinks
4. Ensure all eref elements generate hyperlinks

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `insert_bookmark`, `visit_figure`, `visit_table`
- `lib/isodoc/iso/docx/inline.rb` — `render_xref`, `render_eref`, `render_fmt_xref`
