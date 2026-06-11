# 084: Missing inline page breaks between major sections

## Problem
The reference uses `<w:br w:type="page"/>` (inline page breaks) to force each major section to start on a new page. The output only has sectPr-based section breaks but is missing inline page breaks within sections.

## Reference inline page breaks:
Found at paragraphs before annexes and before bibliography. These are separate paragraphs containing ONLY a page break run.

## Output:
The page breaks were added before annexes in the previous fix (render_annex_title adds a PB paragraph). But there should also be page breaks before bibliography and potentially other sections.

## Fix
Already partially fixed. Verify that:
1. Page break exists before each annex ✓
2. Page break exists before bibliography ✓
3. No page breaks between foreword/introduction (these are continuous)

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `render_annex_title`, `visit_remaining_bibliography`
