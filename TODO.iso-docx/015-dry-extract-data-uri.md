# 015 — DRY: move extract_data_uri_to_tempfile to ModelUtils [DONE]

## Problem
`extract_data_uri_to_tempfile` is duplicated in both `adapter.rb` (line 570) and
`inline.rb` (line 412). Both classes include `ModelUtils` — the method belongs there.

Also removes the lazy `require "tempfile"` from inside the method body in inline.rb.

## Fix
1. Move `extract_data_uri_to_tempfile` to `ModelUtils`
2. Move `require "base64"` and `require "tempfile"` to `model_utils.rb` top
3. Remove duplicate from `adapter.rb` and `inline.rb`
4. Remove `require "base64"` from `inline.rb` (no longer needed there)

## Files
- `lib/isodoc/iso/docx/model_utils.rb` (add method)
- `lib/isodoc/iso/docx/adapter.rb` (remove duplicate)
- `lib/isodoc/iso/docx/inline.rb` (remove duplicate, remove base64 require)
