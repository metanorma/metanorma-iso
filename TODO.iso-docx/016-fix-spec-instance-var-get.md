# 016 — Fix inline_renderer_spec.rb: remove instance_variable_get [DONE]

## Problem
`spec/isodoc/docx/inline_renderer_spec.rb` uses `instance_variable_get` to extract
text from built paragraph/run objects (lines 20, 27, 33). This breaks encapsulation
and is a forbidden pattern per code quality rules.

## Fix
Replace `extract_text_from_para` helper with a method that uses public API.
Generate a DOCX, extract the XML, and assert on text content instead of
reaching into object internals.

Alternative: if ParagraphBuilder or the built model exposes a public text accessor,
use that. Otherwise, convert to integration-style specs that generate DOCX output.

## Files
- `spec/isodoc/docx/inline_renderer_spec.rb`
