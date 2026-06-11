# 010 — Table cell paragraph styles

## Problem
Table cell paragraphs have no w:pStyle — all 133 unstyled paragraphs in the rice output
are table cells. In ISO DOCX, header cells should use `Tableheader` style and body cells
should use `Tablebody` style (from the DIS template style mapping).

## Fix
In `render_table_section`, determine if the row is in thead (header) or tbody/tfoot (body),
and apply the appropriate style to each cell paragraph:
- Header rows → `Tableheader`
- Body rows → `Tablebody`

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `render_table_section`
