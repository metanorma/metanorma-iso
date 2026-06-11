# 013 — Comprehensive style and structure specs

## Problem
Current specs verify DOCX generation and bibliography character styles, but don't
verify:
- Paragraph styles for all element types (notes, examples, foreword text, etc.)
- Table cell paragraph styles
- Hyperlink character style
- Header/footer reference presence in sectPr
- Numbering references for ordered/unordered lists

## Fix

### Critical bug found and fixed: case/when dispatch order

The `visit_block` case/when dispatch had three inheritance mismatches:
1. `OrderedList < UnorderedList` — OrderedList matched UnorderedList clause first
2. `QuoteBlock < ParagraphBlock` — Quote matched Paragraph clause first
3. `AdmonitionBlock < ParagraphBlock` — Admonition matched Paragraph clause first

Rule: **subclass must appear before superclass** in case/when.

### Annex heading depth fix

Annex sub-clauses (A.1, A.2) were rendered with `Heading1` instead of `a2`.
Root cause: `visit_annex` didn't set `section_depth = 1`, so the first
clause inside an annex started at depth 1 instead of 2.

Fix: Set `@context.section_depth = 1` when entering an annex.

### Specs added (26 new examples)

All in `spec/isodoc/docx/integration_spec.rb`:

1. **Table structure** — Tableheader style for header cells, Tablebody for body cells,
   Tabletitle0 for table titles
2. **Hyperlink rendering** — Hyperlink rStyle on runs, r:id referencing relationships
3. **Header/footer references** — headerReference/footerReference in sectPr, files exist,
   footer contains page number field, r:id matches document.xml.rels
4. **List numbering** — dash_list numId 10, decimal numId 1, alpha numId 6
5. **Paragraph style assignment** — ForewordTitle, ForewordText, IntroTitle, Note0,
   Example0, BodyText, ANNEX, Code, BlockText, TermNum
6. **Context-aware resolution** — RefNorm for normative, BiblioEntry for informative,
   std* character styles on bibliography spans
7. **Heading levels** — Heading1-3, a2 for annex sub-clauses

## Files
- `spec/isodoc/docx/integration_spec.rb` (rewritten with comprehensive specs)
- `lib/isodoc/iso/docx/adapter.rb` (fixed dispatch order, annex depth)
