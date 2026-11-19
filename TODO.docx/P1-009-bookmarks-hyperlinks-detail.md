# 089: Missing 190 bookmarks and 45 hyperlinks

status: partial

## Status (measured on rice, base 7774b78e)
- Before: 125 bookmarks, 76 hyperlinks. After: 195 bookmarks (all unique), 85 hyperlinks. Reference: 293 / 120.
- Figures, tables, formulas, headings, terms and bib items already had bookmarks; the premise that figures/tables lacked them was false.
- Fixed: paragraphs with an id now get a bookmark (+70); fmt-concept now renders its xref as a hyperlink (+9, also restores the "(3.1)" display text).
- Remaining delta: ~26 _Toc hyperlinks (toc_builder lane); ~98 bookmarks the reference carries on notes, lists, dl, termnote/termexample, quote, sourcecode and some clauses (Word-authored GUID bookmarks, no xref targets them); term anchors differ (ref `paddy`, source `term-paddy`); 11 table-footnote hyperlinks.

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
