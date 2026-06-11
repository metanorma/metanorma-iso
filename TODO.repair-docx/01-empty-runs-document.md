# TODO 01: Empty runs in document.xml (DONE)

## Problem
Word strips runs that have no content elements (`w:t`, `w:br`, `w:tab`, etc.).
Our adapter created runs with only `<w:rPr>` (formatting) but no text/content.

## Fix
- **Reconciler `empty_run?`**: Expanded to check ALL content-carrying attributes
  (break, tab, drawings, pictures, alternate_content, footnote/endnote refs,
  field_char, instr_text, position_tab, del_text, no_break_hyphen, sym,
  last_rendered_page_break). Only runs with ONLY formatting properties (rPr)
  and no content are stripped. Runs with breaks, watermarks, drawings, etc.
  are preserved.
- **Reconciler `strip_empty_runs`**: Runs on document body paragraphs, footnote
  entries, endnote entries, header paragraphs, and footer paragraphs.

## Verification
- `grep -c '<w:r>' word/document.xml` should match repaired count
- No runs with only `<w:rPr>...</w:rPr>` (no content child) in output
- Page breaks (`w:br`), watermarks (`w:pict`), drawings preserved
