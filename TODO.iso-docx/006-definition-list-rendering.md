# 006 — Definition list rendering for terms

## Problem
Term definitions use `<dl>` (definition lists) for key-value pairs in the "Key"
sections of figures/tables. The current `visit_definition_list` creates plain
paragraphs without any special formatting.

## Fix
- Render dt/dd pairs with appropriate styles
- Key title paragraphs should use `KeyTitle` style
- Key entries use body text style

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `visit_definition_list`
